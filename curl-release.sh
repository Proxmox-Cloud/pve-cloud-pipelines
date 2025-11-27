curl --request POST \
  --form "token=${CI_JOB_TOKEN}" \
  --form "ref=${NEW_TAG}" \
  "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/trigger/pipeline"