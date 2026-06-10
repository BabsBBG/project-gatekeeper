# Project Gatekeeper
## Post‑Acquisition Identity Security & ITDR for Helix Communications

**Client:** Helix Communications (Fictional – modelled on real ISP merger)  
**Engineer:** Tobi Babalola

---

## Overview

Helix Communications, a publicly listed ISP, acquired Pulse Networks, a smaller regional ISP, in March 2026. Overnight the identity attack surface doubled: 400+ new identities, stale accounts, no MFA, standing admin privileges, unmanaged contractors, and zero detection capability.

**Project Gatekeeper** is a complete identity security overhaul built for this exact scenario. Every control – from tenant hardening to automated incident response – was designed, deployed, and **tested live** in a Microsoft lab environment (Entra ID P2, Sentinel, Logic Apps). No theory, no "report‑only" screenshots that were never switched on.

The acquisition narrative is fictional, but the work is real. It mirrors the recent Legend‑Spectranet merger in Nigeria, where I previously worked NOC.

---

## Architecture
┌─────────────────────────────────────────────────────────────────────────────────┐
│ HELIX COMMUNICATIONS – AZURE TENANT │
│ (bbgseclab.onmicrosoft.com) │
└─────────────────────────────────────────────────────────────────────────────────┘
│
┌────────────────────────────────┼────────────────────────────────────────┐
│ │ │
┌───────▼────────┐ ┌────────────────────▼────────────────────┐ ┌───────────────▼────────┐
│ PULSE LEGACY │ │ ENTRA ID GOVERNANCE LAYER │ │ DETECTION & RESPONSE │
│ USERS │ │ ┌──────────────────────────────────────┐│ │ ┌─────────────────┐ │
│ ┌────────────┐ │ │ │ PHASE 1 – IDENTITY BASELINE ││ │ │ MICROSOFT │ │
│ │pls-oleksandr│ │ │ │ 7 groups, break‑glass, 16 users, ││ │ │ SENTINEL │ │
│ │.zinchenko │ │──┼──│ E5 licences, SSPR, auth hardening ││ │ │ 14 KQL rules │ │
│ └────────────┘ │ │ └──────────────────────────────────────┘│ │ └─────────────────┘ │
│ ┌────────────┐ │ │ ┌──────────────────────────────────────┐│ │ │ │
│ │pls-reiss. │ │ │ │ PHASE 2 – CONDITIONAL ACCESS ││ │ ┌─────────▼─────────┐ │
│ │nelson │ │──┼──│ 5 named locations, 7 CA policies ││ │ │ LOGIC APPS SOAR │ │
│ └────────────┘ │ │ │ (MFA, risk, legacy block, guests) ││ │ │ Revoke → Disable │ │
│ ┌────────────┐ │ │ └──────────────────────────────────────┘│ │ │ → Offboard → Alert│ │
│ │pls-jakub. │ │ │ ┌──────────────────────────────────────┐│ │ └─────────────────┘ │
│ │kiwior │ │ │ │ PHASE 3 – PRIVILEGED IDENTITY MGMT ││ │ │ │
│ └────────────┘ │ │ │ PIM roles, approver group, JIT, ││ │ ┌─────────▼─────────┐ │
│ ┌────────────┐ │ │ │ access reviews, activation sim ││ │ │ SOC / ADMIN TEAM │ │
│ │pls-albert. │ │ │ └──────────────────────────────────────┘│ │ │ Alert email, │ │
│ │lokonga │ │ │ ┌──────────────────────────────────────┐│ │ │ incident response │ │
│ └────────────┘ │ │ │ PHASE 4 – LIFECYCLE WORKFLOWS (JML) ││ │ └──────────────────┘ │
│ No MFA │ │ │ Joiner (TAP) / Mover / Leaver ││ │ │
│ Stale │──┼──│ (HLX‑Offboarding trigger) ││ └────────────────────────┘
│ Over‑priv │ │ └──────────────────────────────────────┘│
└────────────────┘ └───────────────────────────────────────────┘

text

All traffic flows through Conditional Access. Privileged access is JIT via PIM. Identity lifecycle is fully automated. Detection feeds Sentinel. Response is a single Logic Apps playbook that contains compromised accounts in under 60 seconds.

---

## What Was Built

| Layer | Service | Configuration |
|-------|---------|---------------|
| Identity Baseline | Entra ID P2 | 7 groups, 16 Helix + Pulse users, break‑glass accounts, E5 licences, SSPR |
| Authentication | Entra ID Auth Methods | Microsoft Authenticator, FIDO2, TAP – SMS/voice disabled |
| Conditional Access | Entra ID CA | 5 named locations, 7 policies (MFA, risk, legacy block, guests, partner network) |
| Privileged Access | Entra ID PIM | Global Admin (4h, MFA, approval), Security Admin (8h, MFA), Privileged Role Admin (4h, MFA, approval), monthly access review |
| Lifecycle Automation | Entra ID Governance | Joiner (TAP), Mover (department change), Leaver (offboarding) workflows – all tested |
| Detection | Microsoft Sentinel | 14 custom KQL rules (break‑glass, impossible travel, password spray, etc.) |
| Response | Logic Apps SOAR | HTTP trigger → revoke sessions → disable account → add to HLX‑Offboarding → SOC email. Break‑glass excluded. |
| Infrastructure as Code | Terraform | Groups, users, CA policies, PIM assignments, Sentinel workspace – ready for a fresh tenant |

---

## Implementation – The Six Phases

### Phase 1 – Identity Baseline & Tenant Hardening

**Objective:** Know what you have, then lock the doors.

Audited the Helix tenant and created a clean group taxonomy: IT Admins, NOC Engineers, Corporate Staff, Field Ops, Break‑Glass, PIM Approvers, and PLS‑Legacy‑Users.

Two break‑glass accounts (`bg-01`, `bg-02`) were created with Global Admin – credentials stored offline, never used day‑to‑day.

Using PowerShell, I bulk‑created 16 users (Helix staff + Pulse legacy accounts). Each Pulse account had a specific gap: no MFA, stale login, over‑privileged, or unlicensed.

Assigned M365 E5 licenses, hardened authentication methods (Microsoft Authenticator, FIDO2, TAP – no SMS/voice), and enabled SSPR with two‑method reset.

**Result:** A clean baseline with documented Pulse legacy risks. Identity Secure Score: N/A → 46.67% after 24h.

📸 [`phase1-task2-groups-list.png`](screenshots/phase1-task2-groups-list.png) · [`phase1-task6-auth-methods.png`](screenshots/phase1-task6-auth-methods.png)

---

### Phase 2 – Conditional Access Architecture

**Objective:** Control how they get in.

Created 5 named locations:

- Helix‑HQ‑London (trusted, UK)
- Helix‑NOC‑Floor (trusted IP range 10.10.1.0/24)
- Helix‑Field‑Ops (UK + Nigeria)
- Pulse‑Legacy‑Office (known, not trusted)
- Pulse‑Partner‑Network (not trusted IP range 10.20.1.0/24)

Built 7 Conditional Access policies, all eventually set to **Enabled**:

| Policy | Purpose |
|--------|---------|
| CA001 | MFA for all users (excludes break‑glass) |
| CA002 | Block legacy authentication (Exchange ActiveSync, other clients) |
| CA003 | Sign‑in risk (High/Medium) → require MFA, re‑auth every time |
| CA004 | User risk (High) → MFA + password change |
| CA005 | Admin MFA + 4h session, never persistent (targets HLX‑IT‑Admins) |
| CA006 | Guest/contractor MFA + 1h session, never persistent |
| CA007 | Pulse‑Partner‑Network location → MFA + 2h session |

> **Note:** Policies started in report‑only mode (industry best practice) and were enabled after PIM and detection went live.

📸 [`phase2-task1-named-locations.png`](screenshots/phase2-task1-named-locations.png) · [`phase2-task2-all-policies-list.png`](screenshots/phase2-task2-all-policies-list.png)

---

### Phase 3 – Privileged Identity Management

**Objective:** Zero standing privilege.

Configured PIM role settings:

- **Global Administrator** – 4 hours, MFA required, **approval required** (by HLX‑PIM‑Approvers)
- **Security Administrator** – 8 hours, MFA required, no approval
- **Privileged Role Administrator** – 4 hours, MFA required, approval required

Made eligible assignments:

- Martin Odegaard → Global Admin
- Declan Rice → Security Admin
- William Saliba → Privileged Role Admin

Created **HLX‑PIM‑Approvers** group with Jurrien Timber and Kai Havertz – **corporate staff, not IT Admins** – enforcing separation of duties.

Onboarded the HLX‑IT‑Admins group to PIM (group membership is now JIT) and set up a **monthly access review** for Global Administrator (auto‑remove if no response).

**Live simulation:** Odegaard requested Global Admin activation → Timber approved. Audit trail complete.

📸 [`phase3-task2-globaladmin-settings.png`](screenshots/phase3-task2-globaladmin-settings.png) · [`phase3-task3-eligible-assignments.png`](screenshots/phase3-task3-eligible-assignments.png) · [`phase3-task9-timber-approval.png`](screenshots/phase3-task9-timber-approval.png)

---

### Phase 4 – Identity Lifecycle (JML Workflows)

**Objective:** Automate onboarding, transfers, and offboarding.

Using Entra ID Governance (Lifecycle Workflows), built three workflows:

| Workflow | Trigger | Tasks |
|----------|---------|-------|
| HLX‑Joiner‑NewHire | User added to HLX‑New‑Joiners group | Generate TAP, assign default group, send welcome email |
| HLX‑Mover‑DeptTransfer | Department attribute changes | Remove old group, add new group, notify manager |
| HLX‑Leaver‑Offboard | User added to HLX‑Offboarding group | Disable account, remove all groups, strip licences, notify manager (before and on last day) |

**Tested live:**

- Viktor Gyokeres onboarded – TAP generated, group added ✓
- Gabriel Martinelli transferred from Field Ops to Corporate – group updated, manager notified ✓
- Albert Lokonga offboarded – account disabled, groups removed, licence stripped ✓

The Leaver workflow doubles as an **emergency containment action**. When a compromised account is added to HLX‑Offboarding, the workflow fires within seconds.

📸 [`phase4-task2-joiner-workflow.png`](screenshots/phase4-task2-joiner-workflow.png) · [`phase4-task4-leaver-workflow.png`](screenshots/phase4-task4-leaver-workflow.png) · [`phase4-task7-leaver-test.png`](screenshots/phase4-task7-leaver-test.png)

---

### Phase 5 – ITDR: Threat Detection

**Objective:** Watch for what tries to break through.

Enabled Entra ID Protection (MFA registration policy, risk policies wired to CA003/CA004) and Microsoft Defender for Identity.

Wrote **14 custom KQL detection rules** targeting the specific Helix‑Pulse threat model. Five key ones:

| Rule | Severity | What it detects |
|------|----------|------------------|
| Break‑Glass Access | Critical | Any sign‑in to bg‑01 or bg‑02 → P1 incident |
| Impossible Travel | High | Same account signs in from >1 country within 60 min |
| Password Spray | High | Single IP failing sign‑ins against ≥5 accounts |
| Role Outside PIM | High | Direct role assignment bypassing PIM |
| Pulse Legacy Activity | Medium | Any successful sign‑in from pls‑* accounts |

**To prove the rules work, I ran 10 live attack simulations:**

1. **Credential harvest** – Pulse legacy users clicked a phishing link via Attack Simulation Training.
2. **Password spray** – Manual failed logins against all 4 Pulse accounts from the same IP.
3. **Role outside PIM** – Directly assigned a role to a Pulse user (audit log captured).
4. **Mass group change** – Added 3 users to HLX‑IT‑Admins at once (audit log showed bulk addition).
5. **Break‑glass access** – Signed in as bg‑01; CA policies correctly not applied, Identity Protection flagged unfamiliar IP.
6. **Offboarding bypass** – Disabled a user without adding to HLX‑Offboarding (audit log + 50057 error captured).
7. **MFA fatigue** – Repeated MFA denials for a NOC engineer (sign‑in logs showed interrupted → success pattern).
8. **Legacy authentication** – PowerShell Basic Auth to MAPI endpoint → 401 Unauthorized (CA002 blocked it).
9. **Impossible travel** – Signed in from Nigeria → US → Belgium via VPN (logs showed three countries in minutes).
10. **PIM activation anomaly** – Activated Global Admin; audit log timestamp captured.

> “A KQL rule that fires but does nothing is a ticket generator. A Sentinel incident that triggers a Logic Apps playbook that revokes, disables, and offboards – that’s security.”

Every simulation generated **real log entries** that matched the KQL queries – proving detection logic is sound.

📸 [`phase5-task4-kql-folder.png`](screenshots/phase5-task4-kql-folder.png) · [`phase5-sim2-password-spray-logs.png`](screenshots/phase5-sim2-password-spray-logs.png) · [`phase5-vpn-risky-signins.png`](screenshots/phase5-vpn-risky-signins.png)

---

### Phase 6 – Response Automation & Governance

**Objective:** Close the loop.

**First** – enabled all 7 CA policies. No report‑only mode remains.

**Second** – ran access reviews:

- AR002 – Global Administrator monthly review: Jurrien Timber approved Martin Odegaard ✓
- AR003 – Pulse Legacy quarterly review: scope = guest users only (PLS‑Legacy‑Users group) ✓

**Third** – deployed Microsoft Sentinel:

- Log Analytics workspace (`hlx-law-sentinel`)
- Connected Entra ID logs (sign‑in, audit, non‑interactive, risky users)
- Added all 14 KQL rules as scheduled analytics rules (active and enabled)

**Fourth** – built a Logic Apps SOAR playbook (HTTP trigger – lab workaround; production uses Sentinel incident trigger):

1. Condition: check if the account is break‑glass (bg‑01 or bg‑02)
2. **If NOT break‑glass:**
   - Revoke all sessions (Graph API)
   - Disable the account (Microsoft Entra ID action)
   - Add to HLX‑Offboarding (triggers Leaver workflow)
   - Send SOC alert email
3. **If break‑glass:**
   - Only send a P1 alert – **NO auto‑block**

**Test run (pls‑oleksandr.zinchenko):** All actions succeeded within **2.42 seconds**. Account disabled, HLX‑Offboarding membership confirmed, SOC email received.

**Break‑glass test (bg‑01):** Account remained enabled, alert email sent – correct behaviour.

📸 [`phase6-task1-all-ca-enabled.png`](screenshots/phase6-task1-all-ca-enabled.png) · [`phase6-task5-logicapp-run-history.png`](screenshots/phase6-task5-logicapp-run-history.png) · [`phase6-task5-soc-alert-email.png`](screenshots/phase6-task5-soc-alert-email.png)

**Final Identity Secure Score:** 32.04% (baseline was 46.67% – score recalculates after enforcement; expected to rise above 70% in the next cycle).

📸 [`phase6-task6-final-secure-score.png`](screenshots/phase6-task6-final-secure-score.png)

---

## Hiccups & Lessons Learned

### 1. Lifecycle Workflows – 401 Unauthorised

**Hiccup:** When I first tried to access Lifecycle Workflows, I got a 401 error. The feature was completely locked.

**Fix:** Lifecycle Workflows require **Microsoft Entra ID Governance** – an add‑on even with E5. I went to the M365 admin centre, activated a free trial, assigned the licence to my admin account, and the workflows unlocked immediately.

### 2. Access Reviews – The Phantom Portal

**Hiccup:** I created a Global Administrator access review with Jurrien Timber as the reviewer. The review showed “Active” in Entra, but when Timber logged into `myaccess.microsoft.com`, he saw “There are no access reviews assigned to you.”

**Fix:** Microsoft sends the reviewer a **direct email link** when a review starts. In a production tenant, that email arrives immediately. In my trial tenant, the email was delayed – but once it arrived, Timber completed the review directly. I documented this as a trial tenant limitation; the configuration itself is correct.

### 3. Logic Apps Entity Extraction – The Sentinel Trial Curse

**Hiccup:** I built a Logic Apps playbook triggered by “When a Microsoft Sentinel incident is created.” The trigger fired, but the “Entities – Get Accounts” action returned **empty** – no UPN, no account details. My entire SOAR workflow failed.

**Fix:** After hours of debugging, I discovered that Sentinel trial workspaces don’t reliably extract entities from manually created incidents. The pipeline requires a certain volume of production data to work consistently.

**Workaround:** I switched the trigger to **HTTP Request** (webhook) and passed the UPN directly in the JSON payload. The rest of the playbook – revoke, disable, offboard, email – worked perfectly. In a production Sentinel workspace with real data, the native trigger works.

---

## Tech Stack

- **Identity & Access Management** – Microsoft Entra ID P2
- **Conditional Access & PIM** – Entra ID Conditional Access, Privileged Identity Management
- **Lifecycle Automation** – Entra ID Governance (Lifecycle Workflows)
- **Detection** – Microsoft Sentinel (14 custom KQL rules), Entra ID Protection, Microsoft Defender for Identity
- **Response** – Azure Logic Apps (SOAR playbook), Microsoft Graph API
- **Infrastructure as Code** – Terraform, Azure CLI
- **Scripting** – PowerShell, Microsoft Graph PowerShell SDK

---

## Getting Started (Fork & Deploy)

### Prerequisites
- Azure subscription with sufficient credits (or a fresh M365 E5 trial)
- Terraform 1.5+
- Azure CLI

### 1. Clone the repo
```bash
git clone https://github.com/yourusername/project-gatekeeper.git
cd project-gatekeeper/terraform
2. Configure variables
bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your tenant ID, subscription ID, and initial password
3. Deploy with Terraform
bash
terraform init
terraform plan
terraform apply
Note: Terraform creates Entra ID resources (groups, users, CA policies, PIM assignments) and the Sentinel workspace. Lifecycle Workflows (Phase 4) must be created manually. The Logic Apps playbook is deployed via the ARM template in /logic-apps/hlx-soar-playbook.json.

4. Deploy the SOAR playbook
bash
az deployment group create \
  --resource-group hlx-rg-gatekeeper \
  --template-file ../logic-apps/hlx-soar-playbook.json
5. Verify
Entra ID → Users – all 16 Helix + Pulse users present

Conditional Access – 7 policies enabled

Sentinel – 14 analytics rules active

Logic Apps – run history shows successful executions

Screenshots Reference
All screenshots are named according to the phase and task they document (e.g., phase3-task4-pim-approvers-group.png). The full set is available in the /screenshots/ folder.

Connect
LinkedIn – Connect with me

Medium Article – [link coming]

