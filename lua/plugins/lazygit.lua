return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    {
      '<leader>go',
      function()
        local git_root = vim.fs.root(0, '.git')
        if not git_root then
          vim.notify('Not inside a git repository', vim.log.levels.ERROR)
          return
        end

        local branch_result = vim.system({ 'git', '-C', git_root, 'branch', '--show-current' }, { text = true }):wait()
        local branch = vim.trim(branch_result.stdout or '')
        if branch == '' then
          vim.notify('Could not determine current git branch', vim.log.levels.ERROR)
          return
        end

        local remote_result = vim.system({ 'git', '-C', git_root, 'config', '--get', 'remote.origin.url' }, { text = true }):wait()
        local remote_url = vim.trim(remote_result.stdout or '')
        local repo = remote_url:match 'github%.com[:/](.+)%.git$' or remote_url:match 'github%.com[:/](.+)$'
        if not repo then
          vim.notify('Could not determine GitHub repository', vim.log.levels.ERROR)
          return
        end

        local url = string.format('https://github.com/%s/compare/%s?expand=1', repo, branch)
        vim.ui.open(url)
      end,
      desc = 'Open GitHub PR',
    },
  },
}
