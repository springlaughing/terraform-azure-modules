# Changelog

All notable changes to these modules. Versions follow semantic versioning:
MAJOR = breaking change, MINOR = new feature, PATCH = bug fix.

## v1.2.0 (2026-11-01)

- network_bundle: optional `security_rules` per subnet, added to that subnet's NSG.
  Backwards compatible: subnets without `security_rules` behave as in v1.1.0.
- network_bundle: offline tests with a mocked azurerm provider (`terraform test`).

## v1.1.0 (2026-11-01)

- network_bundle: new module. VNet, subnets from a map (for_each), one NSG per subnet,
  default outbound access disabled by default.

## v1.0.0 (2026-11-01)

- linux_vm: new module. One Ubuntu 24.04 VM with its own NIC, SSH-key login only.