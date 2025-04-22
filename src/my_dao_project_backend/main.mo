import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Time "mo:base/Time"; // Import Time module
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import User "User"; // Import the User module
import Blog "Blog"; // Import the Blog module

actor DAO {
  // Removed userManager instantiation

  private let users = HashMap.HashMap<Principal, User.User>(
    0,
    Principal.equal,
    Principal.hash
  );

  private let blogPosts = HashMap.HashMap<Nat, [Blog.BlogPost]>(
    0, 
    Nat.equal,
    func(n: Nat) : Hash.Hash { Nat32.fromNat(n) }
  );

  public type ProposalType = {
    #general;
    #removeMember : Principal;
    #inviteMember : Principal;
    #changeQuorum : Nat;
    #changeName : Text;
    #publishBlogPost : Blog.BlogPost;
  };

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
    proposalType: ProposalType;
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
    proposalType: ProposalType;
  };

  public type OrgPublic = {
    id: Nat;
    name: Text;
    owner: Principal;
    members: [Principal];
    proposals: [ProposalPublic];
    quorum: Nat;
  };

  public type InvitationLink = {
    orgId: Nat;
    invitee: Principal;
    expiration: Time.Time;
    proposalId: Nat;
  };

  private var orgCounter : Nat = 0;
  private let organizations = HashMap.HashMap<Nat, Organization>(
    0,
    Nat.equal,
    func(n: Nat) : Hash.Hash { Nat32.fromNat(n) }
  );

  private let invitations = HashMap.HashMap<Text, InvitationLink>(
    0,
    Text.equal,
    Text.hash
  );

  // Helper function to validate caller
  private func validateCaller(caller: Principal, principal: Principal) : Bool {
    return Principal.equal(caller, principal);
  };

  public shared ({ caller }) func createOrganization(principal: Principal, name: Text) : async Nat {
    // if (not validateCaller(caller, principal)) {
    //   return 0; // Unauthorized
    // };
    
    let id = orgCounter;
    orgCounter += 1;

    let members = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
    members.put(principal, true);

    let org: Organization = {
      id = id;
      name = name;
      owner = principal;
      members = members;
      quorum = 1; // Fixed missing quorum initialization
      proposals = HashMap.HashMap<Nat, Proposal>(0, Nat.equal, func(n: Nat) : Hash.Hash { Nat32.fromNat(n) });
    };

    organizations.put(id, org);

    return id; 
  };

  public shared ({ caller }) func addMember(principal: Principal, orgId: Nat, newMember: Principal) : async Text {
    // if (not validateCaller(caller, principal)) {
    //   return "Unauthorized.";
    // };
    
    switch (organizations.get(orgId)) {
      case (null) { return "Organization not found."; };
      case (?org) {
        if (org.owner != principal) {
          return "Only the organization owner can add members.";
        };

        org.members.put(newMember, true);
        return "Member added successfully.";
      };
    };
  };

  public shared ({ caller }) func createProposal(principal: Principal, orgId: Nat, title: Text, description: Text, deadline: Time.Time) : async Nat {
    // if (not validateCaller(caller, principal)) {
    //   return 0; // Unauthorized
    // };
    
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return 0;
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = title;
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = principal;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline; // Use the provided Time.Time value
          status = "open";
          proposalType = #general;
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func createMemberRemovalProposal(
    principal: Principal, 
    orgId: Nat, 
    memberToRemove: Principal, 
    description: Text, 
    deadline: Time.Time
  ) : async Nat {
    // if (not validateCaller(caller, principal)) {
    //   return 0; // Unauthorized
    // };
    
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return 0;
        };

        if (org.owner == memberToRemove) {
          return 0; // Cannot remove the owner
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = "Remove member: " # Principal.toText(memberToRemove);
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = principal;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline;
          status = "open";
          proposalType = #removeMember(memberToRemove);
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func createInvitationProposal(
    principal: Principal,
    orgId: Nat,
    invitee: Principal,
    description: Text,
    deadline: Time.Time
  ) : async Nat {
    // if (not validateCaller(caller, principal)) {
    //   return 0; // Unauthorized
    // };
    
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return 0;
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = "Invite member: " # Principal.toText(invitee);
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = principal;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline;
          status = "open";
          proposalType = #inviteMember(invitee);
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func createQuorumChangeProposal(
    principal: Principal,
    orgId: Nat,
    newQuorum: Nat,
    description: Text,
    deadline: Time.Time
  ) : async Nat {
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return 0;
        };

        if (newQuorum == 0) {
          return 0; // Prevent setting quorum to 0
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = "Change quorum to: " # Nat.toText(newQuorum);
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = principal;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline;
          status = "open";
          proposalType = #changeQuorum(newQuorum);
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func createNameChangeProposal(
    principal: Principal,
    orgId: Nat,
    newName: Text,
    description: Text,
    deadline: Time.Time
  ) : async Nat {
    // if (not validateCaller(caller, principal)) {
    //   return 0; // Unauthorized
    // };
    
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return 0;
        };
        
        if (Text.size(newName) == 0) {
          return 0; // Prevent empty organization names
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = "Change organization name to: " # newName;
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = principal;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline;
          status = "open";
          proposalType = #changeName(newName);
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  public shared ({ caller }) func createBlogPostProposal(
    principal: Principal,
    orgId: Nat,
    title: Text,
    content: Text,
    description: Text,
    deadline: Time.Time
  ) : async Nat {
    // if (not validateCaller(caller, principal)) {
    //   return 0; // Unauthorized
    // };
    
    switch (organizations.get(orgId)) {
      case (null) { return 0; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return 0;
        };
        
        let blogPost: Blog.BlogPost = {
          id = switch (blogPosts.get(orgId)) {
            case (null) { 0 };
            case (?posts) { posts.size() };
          };
          title = title;
          content = content;
          author = principal;
          timestamp = Time.now();
          orgId = orgId;
        };

        let proposalId = Iter.size(org.proposals.keys());
        let proposal: Proposal = {
          id = proposalId;
          title = "Publish blog post: " # title;
          description = description;
          votes_for = 0;
          votes_against = 0;
          creator = principal;
          voters = HashMap.HashMap<Principal, Bool>(0, Principal.equal, Principal.hash);
          vote_arguments = HashMap.HashMap<Principal, Text>(0, Principal.equal, Principal.hash);
          deadline = deadline;
          status = "open";
          proposalType = #publishBlogPost(blogPost);
        };

        org.proposals.put(proposalId, proposal);
        return proposalId;
      };
    };
  };

  private func generateInvitationId() : Text {
    let timestamp = Time.now();
    let timestampText = Int.toText(timestamp);
    let hashValue = Text.hash(timestampText # Principal.toText(Principal.fromActor(DAO)));
    return timestampText # "-" # Nat32.toText(hashValue);
  };

  public shared ({ caller }) func generateInvitationLink(
    orgId: Nat,
    proposalId: Nat,
    invitee: Principal
  ) : async ?Text {
    // No validation needed here
    switch (organizations.get(orgId)) {
      case (null) { return null; };
      case (?org) {
        switch (org.proposals.get(proposalId)) {
          case (null) { return null; };
          case (?proposal) {
            switch (proposal.proposalType) {
              case (#inviteMember(proposedInvitee)) {
                if (proposedInvitee != invitee) { return null; };
                if (proposal.status != "accepted") { return null; };

                let invitationId = generateInvitationId();
                let invitation: InvitationLink = {
                  orgId = orgId;
                  invitee = invitee;
                  expiration = Time.now() + (7 * 24 * 60 * 60 * 1_000_000_000); // 1 week
                  proposalId = proposalId;
                };

                invitations.put(invitationId, invitation);
                return ?invitationId;
              };
              case (_) { return null; };
            };
          };
        };
      };
    };
  };

  public shared ({ caller }) func acceptInvitation(invitationId: Text) : async Text {
    // No validation needed here
    switch (invitations.get(invitationId)) {
      case (null) { return "Invalid invitation link."; };
      case (?invitation) {
        if (caller != invitation.invitee) {
          return "This invitation is not for you.";
        };

        if (Time.now() > invitation.expiration) {
          invitations.delete(invitationId);
          return "This invitation has expired.";
        };

        switch (organizations.get(invitation.orgId)) {
          case (null) { return "Organization not found."; };
          case (?org) {
            org.members.put(caller, true);
            invitations.delete(invitationId);
            return "Welcome to the organization!";
          };
        };
      };
    };
  };

  public shared ({ caller }) func voteOnProposal(principal: Principal, orgId: Nat, proposalId: Nat, voteFor: Bool, argument: Text) : async Text {

    
    switch (organizations.get(orgId)) {
      case (null) { return "Organization not found."; };
      case (?org) {
        if (org.members.get(principal) == null) {
          return "Only members can vote.";
        };

        switch (org.proposals.get(proposalId)) {
          case (null) { return "Proposal not found."; };
          case (?proposal) {
            if (proposal.status != "open") {
              return "Voting on this proposal has ended.";
            };

            if (Time.now() > proposal.deadline) { 
              return "The voting deadline has passed.";
            };

            if (proposal.voters.get(principal) == null) {
              let voters = proposal.voters;
              let vote_arguments = proposal.vote_arguments;
              voters.put(principal, voteFor);
              vote_arguments.put(principal, argument);

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
                proposalType = proposal.proposalType;
              };

              org.proposals.put(proposalId, updatedProposal);
              
              // Check if all members have voted
              let totalMembersCount = Iter.size(org.members.entries());
              let totalVotersCount = Iter.size(voters.entries());
              
              if (totalMembersCount == totalVotersCount) {
                // All members have voted, finalize immediately
                let totalVotes = updatedProposal.votes_for + updatedProposal.votes_against;
                let newStatus = if (totalVotes >= org.quorum) {
                  if (updatedProposal.votes_for > updatedProposal.votes_against) "accepted" else "rejected"
                } else {
                  "rejected"
                };

                // Execute the proposal based on its type
                switch (updatedProposal.proposalType) {
                  case (#removeMember(memberToRemove)) {
                    if (newStatus == "accepted") {
                      org.members.delete(memberToRemove);
                    };
                  };
                  case (#inviteMember(invitee)) {
                    // No action needed here as invitation link still needs to be generated and accepted
                  };
                  case (#changeQuorum(newQuorum)) {
                    if (newStatus == "accepted") {
                      let updatedOrg: Organization = {
                        id = org.id;
                        name = org.name;
                        owner = org.owner;
                        members = org.members;
                        proposals = org.proposals;
                        quorum = newQuorum;
                      };
                      organizations.put(orgId, updatedOrg);
                    };
                  };
                  case (#changeName(newName)) {
                    if (newStatus == "accepted") {
                      let updatedOrg: Organization = {
                        id = org.id;
                        name = newName;
                        owner = org.owner;
                        members = org.members;
                        proposals = org.proposals;
                        quorum = org.quorum;
                      };
                      organizations.put(orgId, updatedOrg);
                    };
                  };
                  case (#publishBlogPost(blogPost)) {
                    if (newStatus == "accepted") {
                      let orgBlogPosts = switch (blogPosts.get(blogPost.orgId)) {
                        case (null) { [] };
                        case (?posts) { posts };
                      };
                      
                      let updatedPosts = Array.append(orgBlogPosts, [blogPost]);
                      blogPosts.put(blogPost.orgId, updatedPosts);
                    };
                  };
                  case (#general) {};
                };

                // Update the proposal status
                let finalizedProposal = {
                  id = updatedProposal.id;
                  title = updatedProposal.title;
                  description = updatedProposal.description;
                  votes_for = updatedProposal.votes_for;
                  votes_against = updatedProposal.votes_against;
                  creator = updatedProposal.creator;
                  voters = updatedProposal.voters;
                  vote_arguments = updatedProposal.vote_arguments;
                  deadline = updatedProposal.deadline;
                  status = newStatus;
                  proposalType = updatedProposal.proposalType;
                };
                
                org.proposals.put(proposalId, finalizedProposal);
                return "Vote registered and proposal finalized immediately as all members have voted!";
              };
              
              return "Vote and argument registered!";
            } else {
              return "You have already voted on this proposal.";
            }
          };
        };
      };
    };
  };

  public shared ({ caller }) func finalizeProposal(principal: Principal, orgId: Nat, proposalId: Nat) : async Text {
    // if (not validateCaller(caller, principal)) {
    //   return "Unauthorized.";
    // };
    
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

            // Handle member removal if proposal is accepted
            switch (proposal.proposalType) {
              case (#removeMember(memberToRemove)) {
                if (newStatus == "accepted") {
                  org.members.delete(memberToRemove);
                };
              };
              case (#inviteMember(invitee)) {
                if (newStatus == "accepted") {
                  // Invitation approved, but member needs to accept it using the link
                  return "Invitation proposal approved. Generate and share the invitation link.";
                };
              };
              case (#changeQuorum(newQuorum)) {
                if (newStatus == "accepted") {
                  // Create a new organization with updated quorum
                  let updatedOrg: Organization = {
                    id = org.id;
                    name = org.name;
                    owner = org.owner;
                    members = org.members;
                    proposals = org.proposals;
                    quorum = newQuorum;
                  };
                  organizations.put(orgId, updatedOrg);
                };
              };
              case (#changeName(newName)) {
                if (newStatus == "accepted") {
                  // Create a new organization with updated name
                  let updatedOrg: Organization = {
                    id = org.id;
                    name = newName;
                    owner = org.owner;
                    members = org.members;
                    proposals = org.proposals;
                    quorum = org.quorum;
                  };
                  organizations.put(orgId, updatedOrg);
                };
              };
              case (#publishBlogPost(blogPost)) {
                if (newStatus == "accepted") {
                  // Add the blog post to the organization's blog
                  let orgBlogPosts = switch (blogPosts.get(blogPost.orgId)) {
                    case (null) { [] };
                    case (?posts) { posts };
                  };
                  
                  let updatedPosts = Array.append(orgBlogPosts, [blogPost]);
                  blogPosts.put(blogPost.orgId, updatedPosts);
                };
              };
              case (#general) {};
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
              proposalType = proposal.proposalType;
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
              proposalType = p.proposalType;
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
            proposalType = p.proposalType;
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

  public query func getUserByPrincipal(principal: Principal) : async ?User.User {
    users.get(principal)
  };

  public shared func createUserForTesting(name: Text, principal: Principal) : async User.User {
    // Ensure the user is created and stored properly
    switch (users.get(principal)) {
      case (?existingUser) {
        return existingUser; // Return the existing user if already created
      };
      case (null) {
        let newUser = User.createUser(name, principal);
        users.put(principal, newUser); // Store the new user in the HashMap
        return newUser;
      };
    };
  };

  // Define a new public type for invitation information
  public type InvitationInfo = {
    invitationId: Text;
    orgId: Nat;
    orgName: Text;
    expiration: Time.Time;
  };

  public shared query ({ caller }) func getMyInvitations(principal: Principal) : async [InvitationInfo] {
    // if (not validateCaller(caller, principal)) {
    //   return []; // Return empty array if unauthorized
    // };
    
    var myInvitations : [InvitationInfo] = [];
    
    for ((id, invitation) in invitations.entries()) {
      if (invitation.invitee == principal) {
        switch (organizations.get(invitation.orgId)) {
          case (?org) {
            let invitationInfo : InvitationInfo = {
              invitationId = id;
              orgId = invitation.orgId;
              orgName = org.name;
              expiration = invitation.expiration;
            };
            myInvitations := Array.append(myInvitations, [invitationInfo]);
          };
          case (null) { /* Skip if org doesn't exist */ };
        };
      };
    };
    
    return myInvitations;
  };

  public shared ({ caller }) func respondToInvitation(principal: Principal, invitationId: Text, accept: Bool) : async Text {
    // if (not validateCaller(caller, principal)) {
    //   return "Unauthorized.";
    // };
    
    switch (invitations.get(invitationId)) {
      case (null) { return "Invalid invitation link."; };
      case (?invitation) {
        if (principal != invitation.invitee) {
          return "This invitation is not for you.";
        };

        if (Time.now() > invitation.expiration) {
          invitations.delete(invitationId);
          return "This invitation has expired.";
        };

        // Delete the invitation in either case
        invitations.delete(invitationId);

        if (accept) {
          // Accept the invitation
          switch (organizations.get(invitation.orgId)) {
            case (null) { return "Organization not found."; };
            case (?org) {
              org.members.put(principal, true);
              return "You have joined the organization!";
            };
          };
        } else {
          // Reject the invitation
          return "You have declined the invitation.";
        };
      };
    };
  };

  public shared query func getMyOrganizations(principal: Principal) : async [OrgPublic] {
    var myOrgs : [OrgPublic] = [];
    
    // Loop through all organizations and check if the user (principal) is a member
    for (org in organizations.vals()) {
        switch (org.members.get(principal)) {
            case (?_) {
                // User is a member of this organization, include it in the result
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
                            proposalType = p.proposalType;
                        }
                    }
                );

                let orgPublic : OrgPublic = {
                    id = org.id;
                    name = org.name;
                    owner = org.owner;
                    members = memberArray;
                    proposals = proposalArray;
                    quorum = org.quorum;
                };

                myOrgs := Array.append(myOrgs, [orgPublic]);
            };
            case (null) {
                // User is not a member of this organization, skip it
            };
        };
    };

    return myOrgs;
};


  // Query functions for blog posts
  public query func getBlogPosts(orgId: Nat) : async [Blog.BlogPost] {
    switch (blogPosts.get(orgId)) {
      case (null) { [] };
      case (?posts) { posts };
    };
  };

  public query func getBlogPost(orgId: Nat, postId: Nat) : async ?Blog.BlogPost {
    switch (blogPosts.get(orgId)) {
      case (null) { null };
      case (?posts) {
        if (postId >= posts.size()) { return null; };
        ?posts[postId];
      };
    };
  };
};