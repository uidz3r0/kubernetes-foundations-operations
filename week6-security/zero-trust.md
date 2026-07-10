## What you've covered

By the end of Week 6, you've worked through the major Kubernetes security layers:

| Topic                 | Covered                                          |
| --------------------- | ------------------------------------------------ |
| Authentication        | ✔ Kubernetes users & ServiceAccounts             |
| Authorization         | ✔ RBAC                                           |
| Secrets               | ✔ Secrets and External Secrets Operator concepts |
| Network Security      | ✔ NetworkPolicies                                |
| Workload Hardening    | ✔ Security Contexts                              |
| Pod Security          | ✔ Pod Security Admission                         |
| Admission Control     | ✔ Mutating/Validating concepts                   |
| Supply Chain Security | ✔ Trivy, Checkov, image scanning                 |
| Defense in Depth      | ✔ W6D7 Integration Lab                           |

How this aligns with certifications

- CKA: Strong coverage of the security topics expected for cluster administrators.
- CKS: An excellent foundation. The remaining CKS-focused areas are more advanced and include:
  - Falco runtime security
  - seccomp/AppArmor/SELinux
  - Image signing (Cosign, Sigstore)
  - Supply chain security (SBOMs, attestations)
  - Advanced network security (e.g., Cilium, eBPF)
  - Secrets management in cloud providers (AWS Secrets Manager, HashiCorp Vault)

Those fit naturally into your planned `Phase 2 / Advanced Kubernetes` curriculum rather than Phase 1.

Overall, I think Week 6 is now well-balanced: it starts with individual security concepts, introduces production awareness with External Secrets Operator, and finishes with an integration lab that brings the core controls together in a realistic deployment. It's a solid conclusion before moving into Week 7 – Cluster Operations.