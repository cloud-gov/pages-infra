# Architecture

## Quotas
### Space Quotas
| **Quota** | **Total Memory** | **Applications** | **Routes** | **Services** |
| --------- |:----------------:|:----------------:|:----------:|:------------:|
| Service   | 0                | 0                | 0          | &infin;      |
| Tiny      | 1GB              | &infin;          | &infin;    | &infin;      |
| Limited   | 10GB             | &infin;          | &infin;    | &infin;      |
| Unlimited | &infin;&dagger;  | &infin;          | &infin;    | &infin;      |

&dagger; *Up to organization quota*

### Space Quota Assignments
| **Space**     | **Quota** |
| ------------- | --------- |
| production    | Unlimited |
| sites         | Service   |
| email         | Tiny      |
| staging       | Limited   |
| sites-staging | Service   |
| dev           | Limited   |
| sites-dev     | Service   |
| redirects     | Tiny      |
| sandbox       | Tiny      |
| sonarqube     | Limited   |
| \<default\>   | Tiny      |
