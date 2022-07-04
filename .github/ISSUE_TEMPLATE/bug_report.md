name: "Bug report"
description: "Submit a report and help us improve the Monitoring Plugins"
title: '[plugin-name[2|3]: A short sentence describing the problem]'
labels: ["bug"]
assignees: ''
body:
  - type: markdown
    attributes:
      value: |
        ### Thank you for contributing to this project!
        Please note this is a **free and open-source** project. Most people take on their own time to help you, so please, be patient.
        You can obtain [Enterprise support](https://www.linuxfabrik.ch/angebot/service-und-support/) if you run the Monitoring Plugins+ in a mission critical environment.
  - type: checkboxes
    id: before-posting
    attributes:
      label: "⚠️ This issue respects the following points:"
      description: All conditions are **required**. Your issue can be closed if these are checked incorrectly.
      options:
        - label: This is a **bug**, not a question or a setup/configuration issue.
          required: true
        - label: This issue is **not** already reported on Github _(I've searched it)_.
          required: true
        - label: I use the latest release of the Monitoring Plugins (https://github.com/Linuxfabrik/monitoring-plugins/releases).
          required: true
        - label: I agree to follow Monitoring Plugins's [Code of Conduct](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/CODE_OF_CONDUCT.md).
          required: true
  - type: textarea
    id: bug-description
    attributes:
      label: Bug description
      description: |
        Provide a clear and concise description of the bug you're experiencing.
    validations:
      required: true
  - type: textarea
    id: command-line-call
    attributes:
      label: Steps to reproduce - Plugin call
      description: |
        Your plugin command line call (plugin-name --param1=value1 --param2=value2). Example:
        ```/usr/lib64/nagios/plugins/cpu-usage --count 5 --critical 90 --warning 80```
        > NOTE: This will be automatically formatted into code for better readability.
      render: shell
    validations:
      required: true
  - type: textarea
    id: version-result
    attributes:
      label: Steps to reproduce - Plugin Version
      description: |
        Result of ```plugin-name --version```: Example:
        ```2022013101```
    validations:
      required: true
  - type: textarea
    id: data
    attributes:
      label: Steps to reproduce - Data
      description: |
        Enter here the output of your operating system or application (which will be analyzed by the plugin as input), e.g. JSON data, the output of the shell comand that the plugin calls etc.
  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: Please give us as much information as possible about your system. For example, the output of ```uname -a```.
    validations:
      required: true
  - type: textarea
    id: application
    attributes:
      label: Application
      description: Please provide us with as much information as possible about your application, including the version of the monitored application.
    validations:
      required: false
  - type: textarea
    id: pyhton-modules
    attributes:
      label: Python modules
      description: List of enabled python modules etc.
    validations:
      required: false
  - type: textarea
    id: additional-info
    attributes:
      label: Additional info
      description: Any additional information related to the issue.