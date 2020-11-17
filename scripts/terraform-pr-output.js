function displayOutcome(outcome) {
  return outcome === 'success' ? `✅`: `❌` ;
}

module.exports = (github, ctx) => {
  const { PLAN } = process.env;
  const { issue, matrix, repo, steps } = ctx;
    
  const output = `
    ## Terraforming *${matrix.name}*
    #### Format: ${displayOutcome(steps.format.outcome)}
    #### Init:   ${displayOutcome(steps.init.outcome)}
    #### Plan:   ${displayOutcome(steps.plan.outcome)}
    <details>
      <summary>
        Show Plan
      </summary>
      ${PLAN}
    </details>
  `;

  github.issues.createComment({
    issue_number: issue.number,
    owner: repo.owner,
    repo: repo.repo,
    body: output
  });
}