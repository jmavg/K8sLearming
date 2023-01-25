# titre du repo icitte tabarnak!

La description de ce que c'est esti!

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# Development

## Setup

Requirements:
- >= python 3.8
- [pre-commit](https://pre-commit.com/)
- terraform (via [tfenv](https://github.com/tfutils/tfenv) or [tfswitch](https://tfswitch.warrensbox.com/) strongly recommended)
- [terraform-docs](https://github.com/terraform-docs/terraform-docs)
- [tflint](https://github.com/terraform-linters/tflint)
- [checkov](https://www.checkov.io/) (could be installed via pipenv)

 
# Install and setup the environment
pip install --user --upgrade \
  pre-commit \
  checkov

# Ensuring that pre-commit watch this repository
pre-commit install
 
