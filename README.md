# xApp Developement Guide

<table>
  <tr>
    <td align="center" width="50%">
      <img src="res/architecture.gif" alt="Architecture of Near-RT RIC" width="100%">
      <br>
      <sub><b>(a)</b> Architecture of Near-RT RIC.</sub>
    </td>
    <td align="center" width="50%">
      <img src="res/layers.gif" alt="Deployment layers of xApps" width="100%">
      <br>
      <sub><b>(b)</b> Deployment layers of xApps.</sub>
    </td>
  </tr>
</table>


<p align="center">
  <sub>Figures taken from [1].</sub>
</p>

This repo contains tutorials, learning content, and code for building xApps. It will evolve as I learn more!

## Phases

### Phase 1: Environment Setup

I have aimed to setup the whole infrastructure for xApp developement as code (IaC). This means I am using 
[Terraform + Multipass](./DevOps/k8s-multipass-terraform/) to setup a 3-VM Kubernetes cluster. Then I am deploying Near-RT RIC based on the O-RAN documentations, to make it reproducible, I have been using [Ansible](./DevOps/k8s-multipass-terraform/) to setup the nodes, local helm repository, installing Near RT RIC helm charts, and adding the E2 simulator. 


## References

[1] J. F. Santos, A. Huff, D. Campos, K. V. Cardoso, C. B. Both, and L. A. DaSilva, "Managing O-RAN Networks: xApp Development From Zero to Hero," *IEEE Communications Surveys & Tutorials*, vol. 28, pp. 800–840, 2026, doi: [10.1109/COMST.2025.3539687](https://doi.org/10.1109/COMST.2025.3539687).