#!/bin/bash

# Publish the latest version of the SDK to nuget.org

#### FUNCTIONS

usage() {
  echo "Usage: $0 [option...] "
  echo
  echo "  -k, --nuget-api-key       Nuget API Key for publish"
  echo "  -s, --nuget-spec-file     Nuspec file to publish"
  echo
  exit 1
}

timestamp() {
  date +"%T"
}

#### END FUNCTIONS
#### ARGUMENT PROCESSING

while (( "$#" )); do
  case "$1" in
    -k|--nuget-api-key)
      shift
      nuget_api_key=$1
      ;;
    -s|--nuget-spec-file)
      shift
      nuget_spec_file=$1
      ;;
    -h|--help)
      usage
      exit
      ;;
    --) # end of arg parsing
      shift
      break
      ;;
    *)
      usage
      exit 1
      ;;
  esac
  shift
done

if [ -z "$nuget_spec_file" ]
then
  nuget_spec_file="$(find "../YNAB.SDK/bin/Release/" -name "*.nupkg" | sort | tail -1)"
fi

if [ -z "$nuget_api_key" ]
then
  #  Nuget API Key for publishing the package. see \\https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package\\
  echo "Api key is required; please re-run the command and pass the nuget Api Key as first argument"
  exit 1
fi
#### END ARGUMENT PROCESSING
#### VARIABLES

log_path="./publish.log"
echo "PUBLISH STARTED $(timestamp)" | tee $log_path
project_path="../YNAB.SDK/YNAB.SDK.csproj"

#### END VARIABLES
#### MAIN LOGIC

echo "CLEAN STARTED $(timestamp)" | tee -a $log_path
dotnet clean $project_path --configuration Release --verbosity normal | tee -a $log_path

echo "BUILD STARTED $(timestamp)" + timestamp | tee -a $log_path
dotnet build $project_path --configuration Release --force --verbosity normal | tee -a $log_path

echo "PACK STARTED $(timestamp)" + timestamp | tee -a $log_path
dotnet pack $project_path --configuration Release --force --verbosity normal | tee -a $log_path

echo "NUGET PUSH STARTED $(timestamp)" + timestamp | tee -a $log_path
dotnet nuget push $nuget_spec_file --api-key $nuget_api_key --source https://api.nuget.org/v3/index.json | tee -a $log_path

echo "PUBLISH FINISHED $(timestamp)" + timestamp | tee -a $log_path

#### END MAIN LOGIC
