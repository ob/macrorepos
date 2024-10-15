""" git scalar rules """

load("@bazel_tools//tools/build_defs/repo:local.bzl", "local_repository")

# Static list of known macrorepos (could be dynamic)
# TODO: This shouldn't be here, but in a separate file
REMOTES = {
    "base": "",
    "repo-a": "",
}

def scalar_repository(module_ctx, name, commit, destination):
    """ Clone or update a scalar repository

    Args:
        module_ctx: The module context
        name: The name of the repository
        commit: The commit to check out
        destination: The destination directory
    """

    if module_ctx.path(destination).exists:
        # If it is, update it
        module_ctx.report_progress("Updating " + name)
        result = module_ctx.execute(
            ["git", "fetch"],
            working_directory = destination,
        )
        if result.return_code != 0:
            error = "git fetch failed: " + result.stdout + result.stderr
            fail(error)
    else:
        # If it isn't, clone it
        module_ctx.report_progress("Cloning " + name)
        # TODO: This was supposed to be a scalar clone but there are a bunch
        # of versions of scalar that don't have the `--no-src` flag and then
        # you have to deal with the `src` directory. While we test it's fine
        # to just use git clone.
        result = module_ctx.execute(
            [
                "git",
                "clone",
                REMOTES[name],
                destination,
            ],
        )
        if result.return_code != 0:
            error = "scalar clone failed: " + result.stdout + result.stderr
            fail(error)

    # Check out the commit
    print("running git checkout")
    result = module_ctx.execute(
        [
            "git",
            "checkout",
            commit,
        ],
        working_directory = destination,
    )
    if result.return_code != 0:
        error = "git checkout failed: " + result.stdout + result.stderr
        fail(error)

    print("Creating local_repository")
    local_repository(
        name = name,
        path = destination,
    )
