# DevOps

To setup an xApp we have to setup the Near-RT RIC first, which is an O-RAN component that the xApp communicates with to make changes to the network 
and to receive updates, and metrics. To setup [Near-RT RIC we first have to have a k8s cluster](https://openaicellular.github.io/oaic/oran_installation.html) because this component consists of some pods working together. I have chosen to create three actual VMs using terraform with multipass to make it 
reproducible. 



## Resources 
- [O-RAN Near-Real Time RIC Installation Guide](https://openaicellular.github.io/oaic/oran_installation.html)
