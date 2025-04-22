import{H as b,P as m}from"./proxy-09190287.js";import{A as y,i as P,c as B}from"./index-78ed8790.js";const v=new URLSearchParams(window.location.search),i=v.get("orgId");i===null&&(alert("Organization ID is missing."),window.location.href="./main.html");async function d(){const t=new b({host:"http://localhost:4943"});await t.fetchRootKey();const a=y.createActor(P,{agent:t,canisterId:B}),n=await t.getPrincipal();return{actor:a,identity:n}}async function u(){try{const{actor:t}=await d(),a=await t.getOrganization(Number(i));if(!Array.isArray(a)||a.length===0){alert("Organization not found."),window.location.href="./main.html";return}const n=a[0];document.getElementById("orgName").textContent=`Organization: ${n.name}`,document.getElementById("orgOwner").textContent=`Owner: ${m.fromUint8Array(n.owner._arr).toText()}`,document.getElementById("orgQuorum").textContent=`Quorum: ${n.quorum}`;const s=document.getElementById("orgMembers");s.innerHTML="",n.members.length>0?n.members.forEach(e=>{const o=document.createElement("li");o.textContent=m.fromUint8Array(e._arr).toText(),s.appendChild(o)}):s.innerHTML="<li>No members found.</li>";const r=document.getElementById("orgProposals");r.innerHTML="",n.proposals.length>0?n.proposals.forEach(e=>{const o=document.createElement("li");o.textContent=`${e.title} — Type: ${e.type} — Status: ${e.status}`,r.appendChild(o)}):r.innerHTML="<li>No proposals found.</li>"}catch(t){console.error("Error loading organization details:",t),alert("Failed to load organization details. See console.")}}const p=document.getElementById("proposalForm"),l=document.getElementById("proposalFormTitle"),E=document.getElementById("proposalFormFields");function c(t,a){l.textContent=t,E.innerHTML=a,p.style.display="block"}document.getElementById("createInvitationProposalBtn").addEventListener("click",()=>{c("Invite Member",`
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
      `)});document.getElementById("submitProposalBtn").addEventListener("click",async()=>{const{actor:t,identity:a}=await d(),n=BigInt(Date.now())*1000000n,s=7n*24n*60n*60n*1000000000n,r=n+s;try{if(l.textContent==="Invite Member"){const e=document.getElementById("inviteePrincipal").value,o=document.getElementById("invitationDescription").value;await t.createInvitationProposal(i,e,o,r)}else if(l.textContent==="Remove Member"){const e=document.getElementById("memberToRemove").value,o=document.getElementById("kickDescription").value;await t.createMemberRemovalProposal(i,e,o,r)}else if(l.textContent==="Publish Blog Post"){const e=document.getElementById("blogPostTitle").value,o=document.getElementById("blogPostContent").value,g=document.getElementById("blogPostDescription").value;await t.createBlogPostProposal(i,e,o,g,r)}else if(l.textContent==="Change Quorum"){const e=Number(document.getElementById("newQuorum").value),o=document.getElementById("quorumChangeDescription").value;await t.createQuorumChangeProposal(Number(i),e,o,r)}else if(l.textContent==="Change Organization Name"){const e=document.getElementById("newOrgName").value,o=document.getElementById("nameChangeDescription").value;await t.createNameChangeProposal(a,Number(i),e,o,r)}alert("Proposal created successfully!"),p.style.display="none",u()}catch(e){console.error("Error creating proposal:",e),alert("Failed to create proposal. See console.")}});u();
