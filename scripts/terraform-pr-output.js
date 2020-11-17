function displayOutcome(outcome) {
  return outcome === 'success' ? `✅`: `❌` ;
}

module.exports = (github, ctx) => {
  const { PLAN } = process.env;
    
  const output = `
    ## Terraforming *${ctx.matrix.name}*
    #### Format: ${displayOutcome(ctx.steps.format.outcome)}
    #### Init:   ${displayOutcome(ctx.steps.init.outcome)}
    #### Plan:   ${displayOutcome(ctx.steps.plan.outcome)}
    <details>
      <summary>
        Show Plan
      </summary>
      ${PLAN}
    </details>
  `;

  github.issues.createComment({
    issue_number: ctx.issue.number,
    owner: ctx.repo.owner,
    repo: ctx.repo.repo,
    body: output
  });
}