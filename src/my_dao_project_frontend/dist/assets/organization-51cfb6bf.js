import{H as g,P as m}from"./proxy-09190287.js";import{A as b,i as y,c as P}from"./index-35d735fc.js";const f=new URLSearchParams(window.location.search),a=f.get("orgId");a===null&&(alert("Organization ID is missing."),window.location.href="./main.html");async function d(){const t=new g({host:"http://localhost:4943"});return await t.fetchRootKey(),b.createActor(y,{agent:t,canisterId:P})}async function u(){try{const n=await(await d()).getOrganization(Number(a));if(!Array.isArray(n)||n.length===0){alert("Organization not found."),window.location.href="./main.html";return}const e=n[0];document.getElementById("orgName").textContent=`Organization: ${e.name}`,document.getElementById("orgOwner").textContent=`Owner: ${m.fromUint8Array(e.owner._arr).toText()}`,document.getElementById("orgQuorum").textContent=`Quorum: ${e.quorum}`;const o=document.getElementById("orgMembers");o.innerHTML="",e.members.length>0?e.members.forEach(l=>{const s=document.createElement("li");s.textContent=m.fromUint8Array(l._arr).toText(),o.appendChild(s)}):o.innerHTML="<li>No members found.</li>";const i=document.getElementById("orgProposals");i.innerHTML="",e.proposals.length>0?e.proposals.forEach(l=>{const s=document.createElement("li");s.textContent=`${l.title} — Type: ${l.type} — Status: ${l.status}`,i.appendChild(s)}):i.innerHTML="<li>No proposals found.</li>"}catch(t){console.error("Error loading organization details:",t),alert("Failed to load organization details. See console.")}}const p=document.getElementById("proposalForm"),r=document.getElementById("proposalFormTitle"),h=document.getElementById("proposalFormFields");function c(t,n){r.textContent=t,h.innerHTML=n,p.style.display="block"}document.getElementById("createInvitationProposalBtn").addEventListener("click",()=>{c("Invite Member",`
        <label for="inviteePrincipal">Invitee Principal:</label>
        <input type="text" id="inviteePrincipal" />
        <label for="invitationDescription">Description:</label>
        <textarea id="invitationDescription"></textarea>
      `)});document.getElementById("createKickProposalBtn").addEventListener("click",()=>{c("Remove Member",`
        <label for="memberToRemove">Member Principal to Remove:</label>
        <input type="text" id="memberToRemove" />
        <label for="kickDescription">Description:</label>
        <textarea id="kickDescription"></textarea>
      `)});document.getElementById("createBlogPostProposalBtn").addEventListener("click",()=>{c("Publish Blog Post",`
        <label for="blogPostTitle">Blog Post Title:</label>
        <input type="text" id="blogPostTitle" />
        <label for="blogPostContent">Content:</label>
        <textarea id="blogPostContent"></textarea>
        <label for="blogPostDescription">Description:</label>
        <textarea id="blogPostDescription"></textarea>
      `)});document.getElementById("createQuorumChangeProposalBtn").addEventListener("click",()=>{c("Change Quorum",`
        <label for="newQuorum">New Quorum:</label>
        <input type="number" id="newQuorum" />
        <label for="quorumChangeDescription">Description:</label>
        <textarea id="quorumChangeDescription"></textarea>
      `)});document.getElementById("createNameChangeProposalBtn").addEventListener("click",()=>{c("Change Organization Name",`
        <label for="newOrgName">New Organization Name:</label>
        <input type="text" id="newOrgName" />
        <label for="nameChangeDescription">Description:</label>
        <textarea id="nameChangeDescription"></textarea>
      `)});document.getElementById("submitProposalBtn").addEventListener("click",async()=>{const t=await d(),n=Math.floor(Date.now()/1e3)+7*24*60*60;try{if(r.textContent==="Invite Member"){const e=document.getElementById("inviteePrincipal").value,o=document.getElementById("invitationDescription").value;await t.createInvitationProposal(a,e,o,n)}else if(r.textContent==="Remove Member"){const e=document.getElementById("memberToRemove").value,o=document.getElementById("kickDescription").value;await t.createMemberRemovalProposal(a,e,o,n)}else if(r.textContent==="Publish Blog Post"){const e=document.getElementById("blogPostTitle").value,o=document.getElementById("blogPostContent").value,i=document.getElementById("blogPostDescription").value;await t.createBlogPostProposal(a,e,o,i,n)}else if(r.textContent==="Change Quorum"){const e=Number(document.getElementById("newQuorum").value),o=document.getElementById("quorumChangeDescription").value;await t.createQuorumChangeProposal(Number(a),e,o,n)}else if(r.textContent==="Change Organization Name"){const e=document.getElementById("newOrgName").value,o=document.getElementById("nameChangeDescription").value;await t.createNameChangeProposal(a,e,o,n)}alert("Proposal created successfully!"),p.style.display="none",u()}catch(e){console.error("Error creating proposal:",e),alert("Failed to create proposal. See console.")}});u();
