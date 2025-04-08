import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface OrgPublic {
  'id' : bigint,
  'members' : Array<Principal>,
  'owner' : Principal,
  'name' : string,
  'proposals' : Array<ProposalPublic>,
}
export interface ProposalPublic {
  'id' : bigint,
  'title' : string,
  'creator' : Principal,
  'description' : string,
  'voters' : Array<[Principal, boolean]>,
  'votes_for' : bigint,
  'vote_arguments' : Array<[Principal, string]>,
  'votes_against' : bigint,
}
export interface _SERVICE {
  'addMember' : ActorMethod<[bigint, Principal], string>,
  'createOrganization' : ActorMethod<[string], bigint>,
  'createProposal' : ActorMethod<[bigint, string, string], bigint>,
  'getAllOrganizations' : ActorMethod<[], Array<OrgPublic>>,
  'getOrganization' : ActorMethod<[bigint], [] | [OrgPublic]>,
  'voteOnProposal' : ActorMethod<[bigint, bigint, boolean, string], string>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
