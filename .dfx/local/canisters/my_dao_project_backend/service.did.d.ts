import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface BlogPost {
  'id' : bigint,
  'title' : string,
  'content' : string,
  'orgId' : bigint,
  'author' : Principal,
  'timestamp' : Time,
}
export interface InvitationInfo {
  'orgName' : string,
  'orgId' : bigint,
  'invitationId' : string,
  'expiration' : Time,
}
export interface OrgPublic {
  'id' : bigint,
  'members' : Array<Principal>,
  'owner' : Principal,
  'name' : string,
  'proposals' : Array<ProposalPublic>,
  'quorum' : bigint,
}
export interface ProposalPublic {
  'id' : bigint,
  'status' : string,
  'title' : string,
  'creator' : Principal,
  'description' : string,
  'deadline' : Time,
  'voters' : Array<[Principal, boolean]>,
  'proposalType' : ProposalType,
  'votes_for' : bigint,
  'vote_arguments' : Array<[Principal, string]>,
  'votes_against' : bigint,
}
export type ProposalType = { 'inviteMember' : Principal } |
  { 'changeName' : string } |
  { 'removeMember' : Principal } |
  { 'publishBlogPost' : BlogPost } |
  { 'general' : null } |
  { 'changeQuorum' : bigint };
export type Time = bigint;
export interface User { 'principal' : Principal, 'name' : string }
export interface _SERVICE {
  'acceptInvitation' : ActorMethod<[string], string>,
  'addMember' : ActorMethod<[bigint, Principal], string>,
  'createBlogPostProposal' : ActorMethod<
    [bigint, string, string, string, Time],
    bigint
  >,
  'createInvitationProposal' : ActorMethod<
    [bigint, Principal, string, Time],
    bigint
  >,
  'createMemberRemovalProposal' : ActorMethod<
    [bigint, Principal, string, Time],
    bigint
  >,
  'createNameChangeProposal' : ActorMethod<
    [bigint, string, string, Time],
    bigint
  >,
  'createOrganization' : ActorMethod<[string], bigint>,
  'createProposal' : ActorMethod<[bigint, string, string, Time], bigint>,
  'createQuorumChangeProposal' : ActorMethod<
    [bigint, bigint, string, Time],
    bigint
  >,
  'createUser' : ActorMethod<[string], User>,
  'createUserForTesting' : ActorMethod<[string, Principal], User>,
  'finalizeProposal' : ActorMethod<[bigint, bigint], string>,
  'generateInvitationLink' : ActorMethod<
    [bigint, bigint, Principal],
    [] | [string]
  >,
  'getAllOrganizations' : ActorMethod<[], Array<OrgPublic>>,
  'getBlogPost' : ActorMethod<[bigint, bigint], [] | [BlogPost]>,
  'getBlogPosts' : ActorMethod<[bigint], Array<BlogPost>>,
  'getMyInvitations' : ActorMethod<[], Array<InvitationInfo>>,
  'getMyOrganizations' : ActorMethod<[], Array<OrgPublic>>,
  'getOrganization' : ActorMethod<[bigint], [] | [OrgPublic]>,
  'getUserByPrincipal' : ActorMethod<[Principal], [] | [User]>,
  'respondToInvitation' : ActorMethod<[string, boolean], string>,
  'voteOnProposal' : ActorMethod<[bigint, bigint, boolean, string], string>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
