require 'yaml'
require 'fileutils'

# iterate through config/sidekiq_workers.yml 
worker_config = YAML.load_file('config/sidekiq_workers.yml')
puts worker_config.inspect
worker_config['queues'].each do |queue|
  # make a deployment for each queue
  deployment = {
    "apiVersion" => "extensions/v1beta1", 
    "kind" => "Deployment", 
    "metadata" => {
       "name" => "#{queue['name']}-workers",
       "namespace" => worker_config["namespace"]
    }, 
    "status" => {}, 
    "spec" => {
      # number of replicas set to the number of workers
      "replicas" => queue["workers"], 
      "strategy" => {
        "type" => "RollingUpdate"
      }, 
      "template" => {
        "spec" => {
          "restartPolicy" => "Always", 
          "imagePullSecrets" => [
            { "name" => "app-secrets" }
          ], 
          "containers" => [
            {
              "command" => [ "/bin/bash" ],
              "args" => ["-c", "bundle exec sidekiq -q #{queue['name']}"],
              "imagePullPolicy" => "Always", 
              "image" => "app-image", 
              "name" => "app", 
              "ports" => [
                { "containerPort" => 3000 }, 
                { "containerPort" => 80 }
              ], 
              "resources" => {},
              "envFrom" => [ "secretRef" => { "name" => "app-secrets" } ]  
            }
          ]
        }
      }
    }
  }

  # generate the deployment file with the correct config
  File.open("k8s/base/workers/#{queue['name']}-deployment.yaml", 'w+') do |file|
    file.write(deployment.to_yaml)
  end
end
