# 
# Define provider parameters
# 
provider "wallarm" {
  api_uuid = "${var.wallarm_api_uuid}"
  api_secret = "${var.wallarm_api_secret}"
  api_host = "${var.api_host}"
}

# 
# Virtual Patch section
# 
resource "wallarm_rule_vpatch" "splunk" {
  attack_type =  ["sqli", "nosqli"]

  action {
    type = "iequal"
    value = "splunk.wallarm-demo.com:88"
    point = {
      header = "HOST"
    }
  }

  point = [["get_all"]]

}

resource "wallarm_rule_vpatch" "tiredful_api" {
  attack_type =  ["any"]

  action {
    point = {
      instance = "9"
    }
  }
  
  action {
    type = "absent"
    point = {
      path = 0
    }
  }

  action {
    type = "equal"
    point = {
      action_name = "formmail"
    }
  }

  action {
    type = "equal"
    point = {
      action_ext = "cgi"
    }
  }

  point = [["uri"]]

}

resource "wallarm_rule_vpatch" "env_sample" {
  attack_type =  ["any"]

  action {
    type = "equal"
    point = {
      action_name = ".env.sample"
    }
  }

  action {
    type = "equal"
    point = {
      action_ext = "php"
    }
  }

  point = [["uri"]]

}

# 
# Regular expression rule section
# 
resource "wallarm_rule_regex" "regex_curltool" {
  regex = ".*curltool.*"
  experimental = false
  attack_type =  "vpatch"

  action {
    type = "iequal"
    value = "tiredful-api.wallarm-demo.com"
    point = {
      header = "HOST"
    }
  }

  point = [["uri"]]

}

# 
# Masking sensitive information rule section
# 
resource "wallarm_rule_masking" "dvwa_sensitive" {

  action {
    point = {
      instance = "5"
    }
  }

  point = [["header", "X-KEY"]]

}

resource "wallarm_rule_masking" "masking_header" {

  action {
    type = "absent"
    point = {
      path = 0
    }
  }

  action {
    type = "equal"
    point = {
      action_name = "masking"
    }
  }

  action {
    type = "absent"
    point = {
      action_ext = ""
    }
  }

  point = [["header", "X-KEY"]]

}

resource "wallarm_rule_masking" "masking_json" {

  action {
    type = "absent"
    point = {
      path = 0
    }
  }

  action {
    type = "equal"
    point = {
      action_name = "masking"
    }
  }

  action {
    type = "absent"
    point = {
      action_ext = ""
    }
  }

  point = [["post"],["json_doc"],["hash", "field"]]

}

# 
# Wallarm mode rule section
# 
resource "wallarm_rule_mode" "wp_mode" {
  mode =  "block"

  action {
    point = {
      instance = "6"
    }
  }

  action {
    type = "iequal"
    value = "monitor"
    point = {
      path = 0
    }
  }

}

resource "wallarm_rule_mode" "tiredful_api_mode" {
  mode =  "monitoring"

  action {
    point = {
      instance = "9"
    }
  }

  action {
    type = "equal"
    point = {
      action_name = "formmail"
    }
  }

}


resource "wallarm_rule_mode" "ad_mode" {
  mode =  "default"

  action {
    type = "equal"
    value = "api"
    point = {
      path = 0
    }
  }

  action {
    type = "equal"
    value = "active-directory"
    point = {
      path = 1
    }
  }

}

resource "wallarm_rule_mode" "dvwa_mode" {
  mode =  "block"

  action {
    type = "equal"
    value = "dvwa.wallarm-demo.com"
    point = {
      header = "HOST"
    }
  }

  action {
    type = "equal"
    point = {
      method = "GET"
    }
  }

}
