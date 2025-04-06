import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";

actor DAO {

  public type Proposal = {
    id: Nat;
    title: Text;
    description: Text;
    votes_for: Nat;
    votes_against: Nat;
    creator: Principal;
    voters: HashMap.HashMap<Principal, Bool>;  
  };

  public type Organization = {
    id: Nat;
    name: Text;
    owner: Principal;
    members: HashMap.HashMap<Principal, Bool>;
    proposals: HashMap.HashMap<Nat, Proposal>;
  };

  public type ProposalPublic = {
    id: Nat;
    title: Text;
    description: Text;
    votes_for: Nat;
    votes_against: Nat;
    creator: Principal;
    voters: [(Principal, Bool)]; 
  };

  public type OrgPublic = {
    id: Nat;
    name: Text;
    owner: Principal;
    members: [Principal]; 
    proposals: [ProposalPublic]; 
  };

  private var orgCounter : Nat = 0;
  private let organizations = HashMap.HashMap<Nat, Organization>(
    0, 
    Nat.equal, 
    func(n: Nat) : Hash.Hash { Nat32.fromNat(n) }
  );

  public shared ({ caller }) func createOrganization(name: Text) : async Nat {
    let id = orgCounter;
    orgCounter += 1;

    let members = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
    members.put(caller, true);

    let org: Organization = {
      id = id;
      name = name;
      owner = caller;
      members = members;
      proposals = HashMap.HashMap<Nat, Proposal>(0, Nat.equal, func(n: Nat) : Hash.Hash { Nat32.fromNat(n) });
    };

    organizations.put(id, org);
    
    return id;  // Just return the organization ID
  };

  public shared ({ caller }) func addMember(orgId: Nat, newMember: Principal) : async Text {
    switch (organizations.get(orgId)) {
      case (null) { return "Organization not found."; };
      case (?org) {
        if (org.owner != caller) {
          return "Only the organization owner can add members.";
        };

        org.members.put(newMember, true);
        return "Member added successfully.";
      };
    };
  };

  public shared ({ caller }) func createProposal(orgId: Nat, title: Text, description: Text) : async Nat {
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(caller) == null) {
          return 0;
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = title;
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = caller;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func voteOnProposal(orgId: Nat, proposalId: Nat, voteFor: Bool) : async Text {
    switch (organizations.get(orgId)) {
      case (null) { return "Organization not found."; };
      case (?org) {
        if (org.members.get(caller) == null) {
          return "Only members can vote.";
        };

        switch (org.proposals.get(proposalId)) {
          case (null) { return "Proposal not found."; };
          case (?proposal) {
            if (proposal.voters.get(caller) == null) {
              let voters = proposal.voters;
              voters.put(caller, voteFor);
              
              let updatedProposal = {
                id = proposal.id;
                title = proposal.title;
                description = proposal.description;
                votes_for = if (voteFor) proposal.votes_for + 1 else proposal.votes_for;
                votes_against = if (not voteFor) proposal.votes_against + 1 else proposal.votes_against;
                creator = proposal.creator;
                voters = voters;
              };

              org.proposals.put(proposalId, updatedProposal);
              return "Vote registered!";
            } else {
              return "You have already voted on this proposal.";
            }
          };
        };
      };
    };
  };

  public query func getOrganization(orgId: Nat) : async ?OrgPublic {
    switch (organizations.get(orgId)) {
      case (null) { return null; };
      case (?org) {
        let memberArray = Iter.toArray(org.members.keys());
        let proposalArray = Array.map<Proposal, ProposalPublic>(
          Iter.toArray(org.proposals.vals()),
          func (p: Proposal) : ProposalPublic {
            {
              id = p.id;
              title = p.title;
              description = p.description;
              votes_for = p.votes_for;
              votes_against = p.votes_against;
              creator = p.creator;
              voters = Iter.toArray(p.voters.entries());
            }
          }
        );

        return ?{
          id = org.id;
          name = org.name;
          owner = org.owner;
          members = memberArray;
          proposals = proposalArray;
        };
      };
    };
  };

  public query func getAllOrganizations() : async [OrgPublic] {
    let orgArray = Iter.toArray(organizations.vals());
    return Array.map<Organization, OrgPublic>(orgArray, func(org) {
      let memberArray = Iter.toArray(org.members.keys());
      let proposalArray = Array.map<Proposal, ProposalPublic>(
        Iter.toArray(org.proposals.vals()),
        func (p: Proposal) : ProposalPublic {
          {
            id = p.id;
            title = p.title;
            description = p.description;
            votes_for = p.votes_for;
            votes_against = p.votes_against;
            creator = p.creator;
            voters = Iter.toArray(p.voters.entries());
          }
        }
      );

      return {
        id = org.id;
        name = org.name;
        owner = org.owner;
        members = memberArray;
        proposals = proposalArray;
      };
    });
  };
};