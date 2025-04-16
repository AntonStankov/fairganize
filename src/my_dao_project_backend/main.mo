import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Time "mo:base/Time"; // Import Time module
import User "User"; // Import the User module

actor DAO {
  // Removed userManager instantiation

  public type Proposal = {
    id: Nat;
    title: Text;
    description: Text;
    votes_for: Nat;
    votes_against: Nat;
    creator: Principal;
    voters: HashMap.HashMap<Principal, Bool>;
    vote_arguments: HashMap.HashMap<Principal, Text>;
    deadline: Time.Time; // Use Time.Time explicitly
    status: Text;   // "open", "accepted", "rejected"
  };

  public type Organization = {
    id: Nat;
    name: Text;
    owner: Principal;
    members: HashMap.HashMap<Principal, Bool>;
    proposals: HashMap.HashMap<Nat, Proposal>;
    quorum : Nat;
  };

  public type ProposalPublic = {
    id: Nat;
    title: Text;
    description: Text;
    votes_for: Nat;
    votes_against: Nat;
    creator: Principal;
    voters: [(Principal, Bool)];
    vote_arguments: [(Principal, Text)];
    deadline: Time.Time; // Use Time.Time explicitly
    status: Text;
  };

  public type OrgPublic = {
    id: Nat;
    name: Text;
    owner: Principal;
    members: [Principal];
    proposals: [ProposalPublic];
    quorum: Nat;
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
      quorum = 1; // Fixed missing quorum initialization
      proposals = HashMap.HashMap<Nat, Proposal>(0, Nat.equal, func(n: Nat) : Hash.Hash { Nat32.fromNat(n) });
    };

    organizations.put(id, org);

    return id; 
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

  public shared ({ caller }) func createProposal(orgId: Nat, title: Text, description: Text, deadline: Time.Time) : async Nat {
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
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline; // Use the provided Time.Time value
          status = "open";
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func voteOnProposal(orgId: Nat, proposalId: Nat, voteFor: Bool, argument: Text) : async Text {
    switch (organizations.get(orgId)) {
      case (null) { return "Organization not found."; };
      case (?org) {
        if (org.members.get(caller) == null) {
          return "Only members can vote.";
        };

        switch (org.proposals.get(proposalId)) {
          case (null) { return "Proposal not found."; };
          case (?proposal) {
            if (proposal.status != "open") {
              return "Voting on this proposal has ended.";
            };

            if (Time.now() > proposal.deadline) { // Compare Time values directly
              return "The voting deadline has passed.";
            };

            if (proposal.voters.get(caller) == null) {
              let voters = proposal.voters;
              let vote_arguments = proposal.vote_arguments;
              voters.put(caller, voteFor);
              vote_arguments.put(caller, argument);

              let updatedProposal = {
                id = proposal.id;
                title = proposal.title;
                description = proposal.description;
                votes_for = if (voteFor) proposal.votes_for + 1 else proposal.votes_for;
                votes_against = if (not voteFor) proposal.votes_against + 1 else proposal.votes_against;
                creator = proposal.creator;
                voters = voters;
                vote_arguments = vote_arguments;
                deadline = proposal.deadline;
                status = proposal.status;
              };

              org.proposals.put(proposalId, updatedProposal);
              return "Vote and argument registered!";
            } else {
              return "You have already voted on this proposal.";
            }
          };
        };
      };
    };
  };

  public shared ({ caller }) func finalizeProposal(orgId: Nat, proposalId: Nat) : async Text {
    switch (organizations.get(orgId)) {
      case (null) { return "Organization not found."; };
      case (?org) {
        switch (org.proposals.get(proposalId)) {
          case (null) { return "Proposal not found."; };
          case (?proposal) {
            if (Time.now() <= proposal.deadline) { // Compare Time values directly
              return "The voting deadline has not passed yet.";
            };

            if (proposal.status != "open") {
              return "This proposal has already been finalized.";
            };

            let totalVotes = proposal.votes_for + proposal.votes_against;
            let newStatus = if (totalVotes >= org.quorum) {
              if (proposal.votes_for > proposal.votes_against) "accepted" else "rejected"
            } else {
              "rejected"
            };

            let finalizedProposal = {
              id = proposal.id;
              title = proposal.title;
              description = proposal.description;
              votes_for = proposal.votes_for;
              votes_against = proposal.votes_against;
              creator = proposal.creator;
              voters = proposal.voters;
              vote_arguments = proposal.vote_arguments;
              deadline = proposal.deadline;
              status = newStatus;
            };

            org.proposals.put(proposalId, finalizedProposal);
            return "Proposal finalized with status: " # newStatus;
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
              deadline = p.deadline; // Use Time directly
              status = p.status; 
              description = p.description;
              votes_for = p.votes_for;
              votes_against = p.votes_against;
              creator = p.creator;
              voters = Iter.toArray(p.voters.entries());
              vote_arguments = Iter.toArray(p.vote_arguments.entries());
            }
          }
        );

        return ?{
          id = org.id;
          name = org.name;
          owner = org.owner;
          members = memberArray;
          proposals = proposalArray;
          quorum = org.quorum;
        }; // Removed invalid status field
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
            deadline = p.deadline;
            status = p.status;
            votes_for = p.votes_for;
            votes_against = p.votes_against;
            creator = p.creator;
            voters = Iter.toArray(p.voters.entries());
            vote_arguments = Iter.toArray(p.vote_arguments.entries());
          }
        }
      );

      return {
        id = org.id;
        name = org.name;
        owner = org.owner;
        members = memberArray;
        proposals = proposalArray;
        quorum = org.quorum
      };
    });
  };

  // UserManager integration
  public shared ({ caller }) func createUser(name: Text) : async User.User {
    // Check if the user already exists
    switch (User.findUser([], caller)) {
      case (?existingUser) {
        return existingUser; // Return the existing user if found
      };
      case (null) {
        return User.createUser(name, caller); // Create a new user if not found
      };
    };
  };

  public query func getUserByPrincipal(principal: Principal) : async ?User.User {
    return User.findUser([], principal); // Updated to use `findUser` with an empty array as a placeholder
  };

  public shared func createUserForTesting(name: Text, principal: Principal) : async User.User {
    // Check if the user already exists
    switch (User.findUser([], principal)) {
      case (?existingUser) {
        return existingUser; // Return the existing user if found
      };
      case (null) {
        return User.createUser(name, principal); // Create a new user if not found
      };
    };
  };
};