# TEST 1: Validate the managed rule's visibility_config.metric_name contains
# the configured `waf_acl_name` (plan-only).  
# Why: catches regressions that change metric-name construction or the
# presence/location of visibility_config for managed rules.
mock_provider "aws" {}

# Mock the aliased provider used by the module (aws.us-east-1) so no credentials are required.
mock_provider "aws" {
  alias = "us-east-1"
}

variables {
  # Minimal required input for the module under test
  waf_acl_name = "test-acl"
}

run "managed_rule_metric_name_includes_acl_name" {
  command = plan

  assert {
    # Walk the set of rules and their visibility_config blocks to find the expected metric name.
    condition = anytrue([
      for r in aws_wafv2_web_acl.this.rule : contains([
        for v in r.visibility_config : v.metric_name
      ], "test-acl-AWSManagedCommonRuleSet-metric")
    ])
    error_message = "managed-rule metric_name must include waf_acl_name to avoid metric collisions across modules"
  }

}
