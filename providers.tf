/*
Set up the providers we are using. Set both the required providers and provide setup 

Example setup:

terraform { 
  required_providers {
    "<local provider name to be used in provider block>" = {
      source                = "provider source>"
      version               = "<version we need>" 
      configuration_aliases = [ <alias for recieving alternate provider configuration from parent module>]
    }
  }
}

provider "<local provider name from required providers>" {
  <settings unique for provider. Look up>
  alias = "<name to use so we can use multiple accounts from provider>"
  
}
*/


terraform { 
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 3.0"
    }
  }
}

provider "aws" {
  #region = var.default_region
  region = "us-east-1"
}


