""" Macrorepos module implementation. """
load("@bazel_features//:features.bzl", "bazel_features")
load("//private:scalar.bzl", "scalar_repository")

def _macrorepos_impl(module_ctx):
    """ Macrorepos module implementation. """

    root_module_direct_deps = []

    for module in module_ctx.modules:
        for tag in module.tags.install:
            for name, version in tag.deps.items():
                home = module_ctx.getenv("HOME", "/tmp") # Default to /tmp if HOME is not set
                root = home + "/mr"
                destination = module_ctx.path(root + "/" + name)
                scalar_repository(
                    module_ctx,
                    name,
                    version,
                    str(destination),
                )
                root_module_direct_deps.append(name)

    return extension_metadata(
        module_ctx,
        root_module_direct_deps = root_module_direct_deps,
        root_module_direct_dev_deps = [],
    )

def extension_metadata(
        module_ctx,
        *,
        root_module_direct_deps = None,
        root_module_direct_dev_deps = None,
        reproducible = False):
    """
        Extension metadata for macrorepos.

        https://bazel.build/rules/lib/builtins/module_ctx#extension_metadata

    Args:
        module_ctx: The module context.
        root_module_direct_deps: The direct dependencies of the root module.
        root_module_direct_dev_deps: The direct dev dependencies of the root module.
        reproducible: Whether the build is reproducible.

    Returns:
        The extension metadata.
    """

    if not hasattr(module_ctx, "extension_metadata"):
        return None
    metadata_kwargs = {}
    if bazel_features.external_deps.extension_metadata_has_reproducible:
        metadata_kwargs["reproducible"] = reproducible
    return module_ctx.extension_metadata(
        root_module_direct_deps = root_module_direct_deps,
        root_module_direct_dev_deps = root_module_direct_dev_deps,
        **metadata_kwargs
    )

_install_tag = tag_class(
    attrs = {
        "deps": attr.string_dict(
            allow_empty = False,
        ),
    },
)

macrorepos = module_extension(
    _macrorepos_impl,
    tag_classes = {
        "install": _install_tag,
    },
)
