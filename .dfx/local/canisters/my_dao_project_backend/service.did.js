export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const User = IDL.Record({ 'principal' : IDL.Principal, 'name' : IDL.Text });
  const BlogPost = IDL.Record({
    'id' : IDL.Nat,
    'title' : IDL.Text,
    'content' : IDL.Text,
    'orgId' : IDL.Nat,
    'author' : IDL.Principal,
    'timestamp' : Time,
  });
  const ProposalType = IDL.Variant({
    'inviteMember' : IDL.Principal,
    'changeName' : IDL.Text,
    'removeMember' : IDL.Principal,
    'publishBlogPost' : BlogPost,
    'general' : IDL.Null,
    'changeQuorum' : IDL.Nat,
  });
  const ProposalPublic = IDL.Record({
    'id' : IDL.Nat,
    'status' : IDL.Text,
    'title' : IDL.Text,
    'creator' : IDL.Principal,
    'description' : IDL.Text,
    'deadline' : Time,
    'voters' : IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Bool)),
    'proposalType' : ProposalType,
    'votes_for' : IDL.Nat,
    'vote_arguments' : IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Text)),
    'votes_against' : IDL.Nat,
  });
  const OrgPublic = IDL.Record({
    'id' : IDL.Nat,
    'members' : IDL.Vec(IDL.Principal),
    'owner' : IDL.Principal,
    'name' : IDL.Text,
    'proposals' : IDL.Vec(ProposalPublic),
    'quorum' : IDL.Nat,
  });
  const InvitationInfo = IDL.Record({
    'orgName' : IDL.Text,
    'orgId' : IDL.Nat,
    'invitationId' : IDL.Text,
    'expiration' : Time,
  });
  return IDL.Service({
    'acceptInvitation' : IDL.Func([IDL.Text], [IDL.Text], []),
    'addMember' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Principal],
        [IDL.Text],
        [],
      ),
    'createBlogPostProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Text, IDL.Text, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createInvitationProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Principal, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createMemberRemovalProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Principal, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createNameChangeProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Text, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createOrganization' : IDL.Func([IDL.Principal, IDL.Text], [IDL.Nat], []),
    'createProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Text, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createQuorumChangeProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createUserForTesting' : IDL.Func([IDL.Text, IDL.Principal], [User], []),
    'finalizeProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat],
        [IDL.Text],
        [],
      ),
    'generateInvitationLink' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Principal],
        [IDL.Opt(IDL.Text)],
        [],
      ),
    'getAllOrganizations' : IDL.Func([], [IDL.Vec(OrgPublic)], ['query']),
    'getBlogPost' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Opt(BlogPost)],
        ['query'],
      ),
    'getBlogPosts' : IDL.Func([IDL.Nat], [IDL.Vec(BlogPost)], ['query']),
    'getMyInvitations' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(InvitationInfo)],
        ['query'],
      ),
    'getMyOrganizations' : IDL.Func(
        [IDL.Principal],
        [IDL.Vec(OrgPublic)],
        ['query'],
      ),
    'getOrganization' : IDL.Func([IDL.Nat], [IDL.Opt(OrgPublic)], ['query']),
    'getUserByPrincipal' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(User)],
        ['query'],
      ),
    'respondToInvitation' : IDL.Func(
        [IDL.Principal, IDL.Text, IDL.Bool],
        [IDL.Text],
        [],
      ),
    'voteOnProposal' : IDL.Func(
        [IDL.Principal, IDL.Nat, IDL.Nat, IDL.Bool, IDL.Text],
        [IDL.Text],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
