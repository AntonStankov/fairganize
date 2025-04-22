import{H as f,P as g}from"./proxy-09190287.js";import{A as E,i as P,c as h}from"./index-78ed8790.js";const B=new URLSearchParams(window.location.search),l=B.get("orgId");l===null&&(alert("Organization ID is missing."),window.location.href="./main.html");let s=null;async function u(){const e=new f({host:"http://localhost:4943"});await e.fetchRootKey();const r=await e.getPrincipal();return s=r,{actor:E.createActor(P,{agent:e,canisterId:h}),identity:r}}async function b(){try{const{actor:e}=await u(),r=await e.getOrganization(Number(l));if(!Array.isArray(r)||r.length===0){alert("Organization not found."),window.location.href="./main.html";return}const a=r[0];document.getElementById("orgName").textContent=`Organization: ${a.name}`,document.getElementById("orgOwner").textContent=`Owner: ${g.fromUint8Array(a.owner._arr).toText()}`,document.getElementById("orgQuorum").textContent=`Quorum: ${a.quorum}`;const n=document.getElementById("orgMembers");n.innerHTML="",a.members.length>0?a.members.forEach(t=>{const i=document.createElement("li");i.textContent=g.fromUint8Array(t._arr).toText(),n.appendChild(i)}):n.innerHTML="<li>No members found.</li>";const o=document.getElementById("orgProposals");o.innerHTML="",a.proposals.length>0?(a.proposals.forEach(t=>{const i=document.createElement("li");i.innerHTML=`
              ${t.title} — Status: ${t.status}
              ${t.status==="open"?`
                <button class="voteTrueBtn" data-proposal-id="${t.id}">Vote True</button>
                <button class="voteFalseBtn" data-proposal-id="${t.id}">Vote False</button>
              `:""}
            `,o.appendChild(i)}),document.querySelectorAll(".voteTrueBtn").forEach(t=>{t.addEventListener("click",async i=>{const p=i.target.getAttribute("data-proposal-id"),m=prompt("Enter your argument for voting true:");m!==null&&await y(p,!0,m)})}),document.querySelectorAll(".voteFalseBtn").forEach(t=>{t.addEventListener("click",async i=>{const p=i.target.getAttribute("data-proposal-id"),m=prompt("Enter your argument for voting false:");m!==null&&await y(p,!1,m)})})):o.innerHTML="<li>No proposals found.</li>",w()}catch(e){console.error("Error loading organization details:",e),alert("Failed to load organization details. See console.")}}async function w(){try{const{actor:e}=await u(),r=await e.getBlogPosts(Number(l)),a=document.getElementById("blogPostsList");a.innerHTML="",r.length>0?r.forEach(n=>{const o=document.createElement("li");o.innerHTML=`
              <strong>${n.title}</strong> by ${g.fromUint8Array(n.author._arr).toText()}
              <br>
              ${n.content}
              <br>
              <em>Published on: ${new Date(Number(n.timestamp)/1e6).toLocaleString()}</em>
              <br><br>
            `,a.appendChild(o)}):a.innerHTML="<li>No blog posts available.</li>"}catch(e){console.error("Error loading blog posts:",e),alert("Failed to load blog posts. See console.")}}const v=document.getElementById("proposalForm"),c=document.getElementById("proposalFormTitle"),I=document.getElementById("proposalFormFields");function d(e,r){c.textContent=e,I.innerHTML=r,v.style.display="block"}document.getElementById("createInvitationProposalBtn").addEventListener("click",()=>{d("Invite Member",`
        <label for="inviteePrincipal">Invitee Principal:</label>
        <input type="text" id="inviteePrincipal" />
        <label for="invitationDescription">Description:</label>
        <textarea id="invitationDescription"></textarea>
      `)});document.getElementById("createKickProposalBtn").addEventListener("click",()=>{d("Remove Member",`
        <label for="memberToRemove">Member Principal to Remove:</label>
        <input type="text" id="memberToRemove" />
        <label for="kickDescription">Description:</label>
        <textarea id="kickDescription"></textarea>
      `)});document.getElementById("createBlogPostProposalBtn").addEventListener("click",()=>{d("Publish Blog Post",`
        <label for="blogPostTitle">Blog Post Title:</label>
        <input type="text" id="blogPostTitle" />
        <label for="blogPostContent">Content:</label>
        <textarea id="blogPostContent"></textarea>
        <label for="blogPostDescription">Description:</label>
        <textarea id="blogPostDescription"></textarea>
      `)});document.getElementById("createQuorumChangeProposalBtn").addEventListener("click",()=>{d("Change Quorum",`
        <label for="newQuorum">New Quorum:</label>
        <input type="number" id="newQuorum" />
        <label for="quorumChangeDescription">Description:</label>
        <textarea id="quorumChangeDescription"></textarea>
      `)});document.getElementById("createNameChangeProposalBtn").addEventListener("click",()=>{d("Change Organization Name",`
        <label for="newOrgName">New Organization Name:</label>
        <input type="text" id="newOrgName" />
        <label for="nameChangeDescription">Description:</label>
        <textarea id="nameChangeDescription"></textarea>
      `)});document.getElementById("submitProposalBtn").addEventListener("click",async()=>{const{actor:e}=await u(),r=BigInt(Date.now())*1000000n,a=7n*24n*60n*60n*1000000000n,n=r+a;try{if(c.textContent==="Invite Member"){const o=document.getElementById("inviteePrincipal").value,t=document.getElementById("invitationDescription").value;await e.createInvitationProposal(s,Number(l),o,t,n)}else if(c.textContent==="Remove Member"){const o=document.getElementById("memberToRemove").value,t=document.getElementById("kickDescription").value;await e.createMemberRemovalProposal(s,Number(l),o,t,n)}else if(c.textContent==="Publish Blog Post"){const o=document.getElementById("blogPostTitle").value,t=document.getElementById("blogPostContent").value,i=document.getElementById("blogPostDescription").value;await e.createBlogPostProposal(s,Number(l),o,t,i,n)}else if(c.textContent==="Change Quorum"){const o=Number(document.getElementById("newQuorum").value),t=document.getElementById("quorumChangeDescription").value;await e.createQuorumChangeProposal(s,Number(l),o,t,n)}else if(c.textContent==="Change Organization Name"){const o=document.getElementById("newOrgName").value,t=document.getElementById("nameChangeDescription").value;await e.createNameChangeProposal(s,Number(l),o,t,n)}alert("Proposal created successfully!"),v.style.display="none",b()}catch(o){console.error("Error creating proposal:",o),alert("Failed to create proposal. See console.")}});async function y(e,r,a){try{const{actor:n}=await u(),o=await n.voteOnProposal(s,Number(l),Number(e),r,a);alert(o),b()}catch(n){console.error("Error voting on proposal:",n),alert("Failed to vote on proposal. See console.")}}b();
