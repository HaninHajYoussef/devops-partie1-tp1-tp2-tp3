# Usage (depuis ~/cicd-lab) : python3 ~/devops-partie1-tp1-tp2-tp3/tp3-cicd-github-actions/snippets/add_version_route.py
p = 'src/app.ts'
s = open(p).read()
route = """app.get('/api/version', (_request, response) => {
  response.json({
    version: process.env.APP_VERSION ?? 'development',
  });
});

"""
if '/api/version' in s:
    raise SystemExit('Route déjà présente')
i = s.index('export default app')
open(p, 'w').write(s[:i] + route + s[i:])
print('Route /api/version ajoutée dans', p)
