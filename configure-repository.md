# Repository Configuration Guide

## Make Repository Public and Configure Branch Protection

### 1. Make Main Branch Public

**Via GitHub Web Interface:**
1. Go to your repository: https://github.com/trefeon/iot-platform
2. Click **Settings** tab
3. Scroll down to **Danger Zone**
4. Click **Change repository visibility**
5. Select **Make public**
6. Type the repository name to confirm: `iot-platform`
7. Click **I understand, change repository visibility**

**Via GitHub CLI (if installed):**
```bash
gh repo edit trefeon/iot-platform --visibility public
```

### 2. Configure Branch Protection for Main

**Via GitHub Web Interface:**
1. Go to **Settings** → **Branches**
2. Click **Add rule** for branch protection
3. Configure the following:
   - **Branch name pattern**: `main`
   - ✅ **Require a pull request before merging**
   - ✅ **Require approvals** (set to 1)
   - ✅ **Dismiss stale PR approvals when new commits are pushed**
   - ✅ **Require review from code owners** (if you create a CODEOWNERS file)
   - ✅ **Require status checks to pass before merging**
   - ✅ **Require branches to be up to date before merging**
   - ✅ **Include administrators** (optional, for strict enforcement)
4. Click **Create**

**Via GitHub CLI:**
```bash
gh api repos/trefeon/iot-platform/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null
```

### 3. Keep Dev Branch Private (if needed)

Since the main repository will be public, the dev branch will also be public. If you need private development:

**Option A: Create a separate private repository for development**
```bash
# Create new private repo
gh repo create trefeon/iot-platform-dev --private --clone

# Add as remote to existing repo
git remote add private https://github.com/trefeon/iot-platform-dev.git

# Push dev branch to private repo
git push private dev
```

**Option B: Use GitHub's internal visibility (for organizations)**
- Only available for GitHub Enterprise or organizations
- Set repository to "Internal" instead of public

### 4. Create CODEOWNERS File (Optional)

```bash
# Create CODEOWNERS file
echo "* @trefeon" > .github/CODEOWNERS
git add .github/CODEOWNERS
git commit -m "Add CODEOWNERS file for code review requirements"
git push origin main
```

### 5. Configure Repository Secrets (for Cloudflare)

**Via GitHub Web Interface:**
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add the following secrets:
   - `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token
   - `CLOUDFLARE_ZONE_ID`: Your domain's zone ID
   - `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID
   - `CF_ACCESS_AUD`: Application audience ID
   - `DOMAIN`: Your domain name

### 6. Set Up Branch Protection for Dev (Optional)

If keeping dev in the same repository:
1. Go to **Settings** → **Branches**
2. Add rule for `dev` branch
3. Configure similar protection as main, but potentially less strict

## Automation Scripts

Run these commands locally to automate some configurations:

```bash
# Set default branch to main (if not already)
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

# Update repository description
gh repo edit trefeon/iot-platform --description "Production-ready IoT platform with FastAPI, MQTT, PostgreSQL, and Cloudflare Zero Trust security"

# Add repository topics
gh repo edit trefeon/iot-platform --add-topic iot,fastapi,mqtt,postgresql,cloudflare,esp32,docker,grafana

# Enable GitHub Pages (if you want documentation site)
gh api repos/trefeon/iot-platform/pages \
  --method POST \
  --field source='{"branch":"main","path":"/"}' \
  --field build_type="legacy"
```

## Verification

After configuration, verify:

1. **Repository is public**: Check https://github.com/trefeon/iot-platform (accessible without login)
2. **Branch protection active**: Try pushing directly to main (should be blocked)
3. **Secrets configured**: Check Settings → Secrets and variables
4. **Topics visible**: Repository should show relevant topics

## Next Steps

1. **Update repository visibility** ✅
2. **Configure branch protection** ✅
3. **Add repository secrets for Cloudflare** ✅
4. **Deploy Cloudflare settings to server** (next task)

Your repository is now ready for public showcase with proper development workflow protection!
