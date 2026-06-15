# Secrets Management

This directory contains encrypted secrets managed with `agenix`.

## Usage

1. Install agenix:
   ```bash
   nix-env -iA nixpkgs.agenix
   ```

2. Encrypt a secret:
   ```bash
   agenix -e secrets/your-secret.age
   ```

3. Decrypt a secret:
   ```bash
   agenix -d secrets/your-secret.age
   ```

## Configuration

Add your secrets to `flake.nix` under `agenix.secrets`:
```nix
agenix = {
  secrets = {
    "your-secret.age".publicKeys = [ "your-gpg-key.pub" ];
  };
};
```

## Example

See `example.age` for a template.
