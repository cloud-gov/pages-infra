function displayOutcome(outcome) {
  return outcome === 'success' ? `✅`: `❌` ;
}

module.exports = ({ github, matrix, steps, context }) => {
  const { PLAN } = process.env;
    
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
    issue_number: context.issue.number,
    owner: context.repo.owner,
    repo: context.repo.repo,
    body: output
  });
}