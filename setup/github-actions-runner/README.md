# GitHub Actions — Self-hosted Runner

Register a self-hosted GitHub Actions runner on Fedora 44 and install it as a
systemd service under a dedicated user.

Upstream documentation:

- <https://docs.github.com/en/actions/concepts/runners/self-hosted-runners>
- <https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners>

## Get the runner agent

In the repository: **Settings → Actions → Runners → New self-hosted runner**.
GitHub then shows the exact download and configuration commands for the current
agent version.

## Download

Commands may vary depending on the agent version shown by GitHub.

```bash
# Create a folder
mkdir actions-runner && cd actions-runner
# Download the latest runner package
curl -o actions-runner-linux-x64-2.334.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.334.0/actions-runner-linux-x64-2.334.0.tar.gz
# Optional: validate the hash
echo "048024cd2c848eb6f14d5646d56c13a4def2ae7ee3ad12122bee960c56f3d271  actions-runner-linux-x64-2.334.0.tar.gz" | shasum -a 256 -c
# Extract the installer
tar xzf ./actions-runner-linux-x64-2.334.0.tar.gz
```

## Configure

Use the URL and registration token shown in the GitHub UI. The token is
short-lived and regenerated each time you open the "New self-hosted runner"
page.

```bash
# Create the runner and start the configuration experience
./config.sh --url https://<github-host>/<org>/<repo> --token <RUNNER_TOKEN>
# Last step, run it!
./run.sh
```

Configuration prompts:

- **Runner group**: press Enter to keep `Default`.
- **Runner name**: set your own, e.g. `shiyatsu-fedora-44`.
- **Additional labels**: add a custom label, e.g. `shiyatsu-fedora-44`. The
  runner already carries the default labels `self-hosted`, `Linux`, `X64`.

Back in **Settings → Actions → Runners**, the runner must now be visible.

## Test the runner

Create `.github/workflows/test-runner.yml`:

```yaml
name: test-runner
on: workflow_dispatch
jobs:
  hello:
    runs-on: [self-hosted, linux, <runner-label>]
    steps:
      - run: echo "Runner OK sur $(hostname)"
      - run: docker --version
```

Replace `<runner-label>` with the custom label set during configuration, then
trigger the workflow manually (`workflow_dispatch`).

## Run as a service (dedicated user)

Create a dedicated user for the runner:

```bash
sudo useradd --create-home --shell /bin/bash git-runner
# Check home folder
ls -ld /home/git-runner

# Docker authorization
sudo usermod -aG docker git-runner
```

Install the runner as a systemd service owned by `git-runner`:

```bash
sudo ./svc.sh install git-runner
```

Adjust ownership of the directory where the runner was installed so the
`git-runner` user can read and write it.
