export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const ProposalPublic = IDL.Record({
    'id' : IDL.Nat,
    'status' : IDL.Text,
    'title' : IDL.Text,
    'creator' : IDL.Principal,
    'description' : IDL.Text,
    'deadline' : Time,
    'voters' : IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Bool)),
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
    'createOrganization' : IDL.Func([IDL.Text], [IDL.Nat], []),
    'createProposal' : IDL.Func(
        [IDL.Nat, IDL.Text, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'finalizeProposal' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Text], []),
    'getAllOrganizations' : IDL.Func([], [IDL.Vec(OrgPublic)], ['query']),
    'getOrganization' : IDL.Func([IDL.Nat], [IDL.Opt(OrgPublic)], ['query']),
    'voteOnProposal' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Bool, IDL.Text],
        [IDL.Text],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
