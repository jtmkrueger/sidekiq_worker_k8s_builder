Sidekiq Worker K8s Builder
--------------------------

A script to generate independent sidekiq worker deployment files for all queue namespaces. I'm using it for Rails projects, but it can be adapted for other things as well.

## Setup

* wget the file to where you're building your workers. This is part of a gitlab pipeline for me, so I'm running this command on in the dockerfile to spin up the runner.

  * `wget https://raw.githubusercontent.com/jtmkrueger/sidekiq_worker_k8s_builder/master/worker_builder.rb`

