export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const User = IDL.Record({ 'principal' : IDL.Principal, 'name' : IDL.Text });
  const ProposalType = IDL.Variant({
    'removeMember' : IDL.Principal,
    'general' : IDL.Null,
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
  return IDL.Service({
    'addMember' : IDL.Func([IDL.Nat, IDL.Principal], [IDL.Text], []),
    'createMemberRemovalProposal' : IDL.Func(
        [IDL.Nat, IDL.Principal, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createOrganization' : IDL.Func([IDL.Text], [IDL.Nat], []),
    'createProposal' : IDL.Func(
        [IDL.Nat, IDL.Text, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'createUser' : IDL.Func([IDL.Text], [User], []),
    'createUserForTesting' : IDL.Func([IDL.Text, IDL.Principal], [User], []),
    'finalizeProposal' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Text], []),
    'getAllOrganizations' : IDL.Func([], [IDL.Vec(OrgPublic)], ['query']),
    'getOrganization' : IDL.Func([IDL.Nat], [IDL.Opt(OrgPublic)], ['query']),
    'getUserByPrincipal' : IDL.Func(
        [IDL.Principal],
        [IDL.Opt(User)],
        ['query'],
      ),
    'voteOnProposal' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Bool, IDL.Text],
        [IDL.Text],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
