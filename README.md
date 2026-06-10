# Project Gatekeeper

## Post-Acquisition Identity Security for a Telecom ISP

**Built by:** Tobi Babalola  
**Scenario:** Helix Communications acquires Pulse Networks – 400+ unmanaged identities, no MFA, stale accounts, standing admin privileges.

---

## Project Overview

**The problem:**  
Helix Communications, a UK ISP, acquired Pulse Networks, a smaller regional ISP. Overnight, the identity attack surface doubled: Pulse had no MFA, stale accounts, standing admin privileges, unmanaged contractors, and zero detection capability.

**The solution:**  
Project Gatekeeper is a complete identity security overhaul built in a live Microsoft lab. Six phases, 14 custom KQL detection rules, 10 live attack simulations, and a SOAR playbook that contains a compromised account in under 60 seconds.

**Key results:**  
- MFA registration: 0% → 100%  
- Legacy authentication: blocked  
- Privileged roles: permanent → JIT with approval  
- Detection rules: 14 custom KQL  
- Automated response: SOAR playbook (2.42 second containment)  
- Identity Secure Score: 46.67% → 32.04% (rising to >70% after full enforcement)

**What you'll see in this walkthrough:**  
Every control I built, from tenant hardening to automated response – with screenshots at each step.

---

## Phase 1 – Identity Baseline

**Goal:** Understand what Pulse brought in, then lock down the foundation.

### 1.1 Create security groups

7 groups: IT Admins, NOC Engineers, Corporate Staff, Field Ops, Break-Glass, PIM Approvers, and Pulse Legacy Users.

![Groups list](Phase%201/phase1-task2-groups-list.png)

### 1.2 Break-glass accounts

Two accounts (`bg-01`, `bg-02`) with permanent Global Admin. Credentials stored offline – never used day-to-day.

![Break-glass members](Phase%201/phase1-task3-breakglass-members.png)

### 1.3 Bulk user creation (PowerShell)

16 users: Helix staff + Pulse legacy accounts.  
Each Pulse account had a specific problem: no MFA, stale, over-privileged, or unlicensed.

![PowerShell creation](Phase%201/phase1-task4-powershell-creation.png)

### 1.4 Licensing and authentication methods

Assigned M365 E5 licences.  
Hardened authentication: Microsoft Authenticator, FIDO2, TAP – no SMS or voice calls.

![Auth methods](Phase%201/phase1-task6-auth-methods.png)

### 1.5 Self-service password reset (SSPR)

Enabled for all users, 2 methods required.

![SSPR methods](Phase%201/phase1-task7-sspr-methods.png)

### 1.6 Pulse legacy gaps – documented and fixed

- Disabled stale account `pls-jakub.kiwior`  
- Removed direct roles from `pls-reiss.nelson` (AI Reader, Directory Readers)

![Kiwior disabled](Phase%201/phase1-task8-kiwior-disabled.png)  
![Nelson roles before removal](Phase%201/phase1-task8-nelson-roles.png)

**Result:** Secure Score baseline = 46.67% after 24 hours.

---

## Phase 2 – Conditional Access

**Goal:** Control who can sign in, from where, and under what conditions.

### 2.1 Named locations

5 locations: Helix HQ, NOC floor (trusted IP), Field Ops, Pulse Legacy Office (not trusted), Pulse Partner Network (not trusted).

![Named locations](Phase%202/phase2-task1-named-locations.png)

### 2.2 Seven CA policies

| Policy | Purpose |
|--------|---------|
| CA001 | MFA for all users (excludes break-glass) |
| CA002 | Block legacy authentication (Exchange ActiveSync, other clients) |
| CA003 | Sign-in risk (High/Medium) → MFA, re-auth every time |
| CA004 | User risk (High) → MFA + password change |
| CA005 | Admin MFA + 4h session, never persistent (targets HLX-IT-Admins) |
| CA006 | Guest/contractor MFA + 1h session |
| CA007 | Pulse-Partner-Network location → MFA + 2h session |

All policies started in report-only mode (industry best practice) and were later enabled.

![CA policy list](Phase%202/phase2-task2-all-policies-list.png)

---

## Phase 3 – Privileged Identity Management

**Goal:** Zero standing privilege. Every admin role must be activated just-in-time.

### 3.1 Role settings

- Global Admin: 4 hours, MFA, approval required  
- Security Admin: 8 hours, MFA, no approval  
- Privileged Role Admin: 4 hours, MFA, approval required

![Global Admin settings](Phase%203/phase3-task2-globaladmin-settings.png)

### 3.2 Eligible assignments

- Martin Odegaard → Global Admin  
- Declan Rice → Security Admin  
- William Saliba → Privileged Role Admin

![Eligible assignments](Phase%203/phase3-task3-eligible-assignments.png)

### 3.3 Approver group (separation of duties)

HLX-PIM-Approvers = Jurrien Timber + Kai Havertz (corporate staff, not IT Admins).

![PIM approvers group](Phase%203/phase3-task4-pim-approvers-group.png)

### 3.4 Monthly access review

Global Administrator role reviewed monthly by Timber. Auto-remove if not approved.

![Access review](Phase%203/phase3-task6-pim-access-review.png)

### 3.5 Live activation simulation

Odegaard requested Global Admin → Timber approved. Full audit trail.

![Activation request](Phase%203/phase3-task9-activation-request.png)  
![Timber approval](Phase%203/phase3-task9-timber-approval.png)

---

## Phase 4 – Lifecycle Workflows (JML)

**Goal:** Automate onboarding, transfers, and offboarding.

### 4.1 Joiner workflow

Trigger: user added to `HLX-New-Joiners`.  
Tasks: Generate TAP, assign default group, send welcome email.

![Joiner workflow](Phase%204/phase4-task2-joiner-workflow.png)

### 4.2 Mover workflow

Trigger: department attribute change.  
Tasks: Remove old group, add new group, notify manager.

![Mover workflow](Phase%204/phase4-task3-mover-workflow.png)

### 4.3 Leaver workflow

Trigger: user added to `HLX-Offboarding`.  
Tasks: Disable account, remove all groups, strip licences, notify manager (before and on last day).

![Leaver workflow](Phase%204/phase4-task4-leaver-workflow.png)

### 4.4 Live tests

- Viktor Gyokeres onboarded – TAP generated ✓  
- Gabriel Martinelli transferred from Field Ops to Corporate – manager notified ✓  
- Albert Lokonga offboarded – account disabled ✓

![Leaver test](Phase%204/phase4-task7-leaver-test.png)  
![Lokonga disabled](Phase%204/phase4-task7-lokonga-disabled.png)

---

## Phase 5 – Threat Detection (ITDR)

**Goal:** Build detection rules that catch Pulse-specific threats, then prove they work.

### 5.1 Entra ID Protection

Enabled MFA registration policy. Wired CA003 (sign-in risk) and CA004 (user risk).

### 5.2 14 custom KQL rules

All in `/kql-queries/`. Five key examples:

| Rule | Severity | What it detects |
|------|----------|------------------|
| Break-Glass Access | Critical | Any sign-in to bg-01 or bg-02 → P1 incident |
| Impossible Travel | High | Same account >1 country within 60 min |
| Password Spray | High | Single IP failing >=5 accounts |
| Role Outside PIM | High | Direct role assignment bypassing PIM |
| Pulse Legacy Activity | Medium | Any sign-in from pls-* accounts |

![KQL folder](Phase%205/phase5-task4-kql-folder.png)

### 5.3 10 live attack simulations – with evidence

1. **Credential harvest** – Attack Simulation Training (Pulse users clicked phishing link)  
   ![Credential harvest results](Phase%205/phase5-sim1-credential-harvest-results.png)

2. **Password spray** – Manual failed logins from same IP across all 4 Pulse accounts  
   ![Password spray logs](Phase%205/phase5-sim2-password-spray-logs.png)

3. **Role outside PIM** – Direct role assignment to Pulse user – audit log captured  
   ![Role outside PIM audit](Phase%205/phase5-sim3-role-outside-pim-audit.png)

4. **Mass group change** – Added 3 users to HLX-IT-Admins at once – audit log shows bulk addition  
   ![Mass group change audit](Phase%205/phase5-sim4-mass-group-change-audit1.png)

5. **Break-glass access** – Signed in as bg-01 – CA policies not applied (correct), Identity Protection flagged unfamiliar IP  
   ![Break-glass signin](Phase%205/phase5-sim5-breakglass-signin.png)

6. **Offboarding bypass** – Disabled a user without HLX-Offboarding – audit log + 50057 error  
   ![Offboarding bypass audit](Phase%205/phase5-sim6-offboarding-bypass-audit.png)

7. **MFA fatigue** – Repeated MFA denials for a NOC engineer – logs show interrupted → success pattern  
   ![MFA fatigue logs](Phase%205/phase5-sim7-mfa-fatigue-signin-logs.png)

8. **Legacy authentication** – PowerShell Basic Auth to MAPI endpoint → 401 Unauthorized (CA002 blocked it)  
   ![Legacy auth 401](Phase%205/phase5-sin8-legacy-auth-401.png)

9. **Impossible travel** – Signed in from Nigeria → US → Belgium via VPN – logs show three countries in minutes  
   ![Impossible travel advanced hunting](Phase%205/phase5-sim9-impossible-travel-advanced-hunting.png)

10. **PIM activation anomaly** – Activated Global Admin – audit log timestamp captured  
    ![PIM activation audit](Phase%205/phase5-sim10-pim-activation-audit.png)

> "A KQL rule that fires but does nothing is a ticket generator. A Sentinel incident that triggers a Logic Apps playbook that revokes, disables, and offboards – that's security."

---

## Phase 6 – Response Automation and Governance

**Goal:** Automate containment and prove the whole system works end-to-end.

### 6.1 Enable all CA policies

No more report-only. All 7 policies = On.

![All CA policies enabled](Phase%206/phase6-task1-all-ca-enabled.png)

### 6.2 Run access reviews

- Global Admin monthly – Timber approved Odegaard ✓  
- Pulse Legacy quarterly – scope = guest users only (PLS-Legacy-Users) ✓

![Access review approval](Phase%206/phase6-task2-access-review-approval.png)

### 6.3 Deploy Sentinel

Log Analytics workspace (`hlx-law-sentinel`). Connected Entra ID logs. Added all 14 KQL rules as scheduled analytics rules.

![LAW workspace](Phase%206/phase6-task4-la-workspace.png)  
![All analytics rules](Phase%206/phase6-task4-all-analytics-rules.png)

### 6.4 Build the SOAR playbook (Logic Apps)

**Trigger:** HTTP webhook (lab workaround – production uses Sentinel incident trigger).  
**Workflow:**  
1. Check if account is break-glass (bg-01 or bg-02)  
2. If NOT break-glass:  
   - Revoke all sessions (Graph API)  
   - Disable account  
   - Add to HLX-Offboarding (triggers Leaver workflow)  
   - Send SOC alert email  
3. If break-glass: only send alert – NO auto-block

![Logic App workflow](Phase%206/phase6-task5-lobigapp-workflow.png)

### 6.5 Test the playbook – compromised account

**Attacker:** pls-oleksandr.zinchenko (Pulse legacy)  
**Action:** revoke, disable, offboard, email – all completed in 2.42 seconds.

![Logic Apps run history](Phase%206/phase6-task5-logicapp-run-history.png)  
![Account disabled](Phase%206/phase6-task5-account-disabled.png)  
![Offboarding group member](Phase%206/phase6-task5-offboarding-group-member.png)  
![SOC alert email](Phase%206/phase6-task5-soc-alert-email.png)

### 6.6 Test the break-glass exclusion

bg-01 accessed → alert sent, account NOT disabled (correct).

![Break-glass alert email](Phase%206/phase6-task5-breachalglass-alert-email.png)  
![Break-glass still enabled](Phase%206/phase6-task5-breachalglass-still-enabl.png)

### 6.7 Final Secure Score

32.04% (baseline was 46.67% – score recalculates after enforcement; expected to rise above 70%).

![Final Secure Score](Phase%206/phase6-task6-fin-al-secure-score.png)

---

## The Results

| Metric | Before | After |
|--------|--------|-------|
| MFA registration | 0% | 100% |
| Legacy authentication | Enabled | Blocked |
| Privileged roles | Permanent | JIT + approval |
| Custom detection rules | None | 14 KQL rules |
| Automated response | None | SOAR playbook |
| Containment time | Hours | <60 seconds |

The real outcome: A compromised account triggers detection, enforcement, and full containment – all without human intervention – in under a minute.

---

## What I Learned (the hard way)

- **Lifecycle Workflows need Entra ID Governance** – a separate trial licence.  
- **Access reviews** – trial tenants don't always show them in the My Access portal, but the email link works.  
- **Sentinel entity extraction is unreliable in trial workspaces** – I had to use an HTTP webhook trigger for the playbook. In production, the native trigger works perfectly.

---

## Reproduce This Project

All code is in this repo: Terraform, KQL rules, PowerShell scripts, and the Logic Apps ARM template.  
See the `terraform/`, `kql-queries/`, `scripts/`, and `logic-apps/` folders.

---

**Built by Tobi Babalola** – now go secure something.