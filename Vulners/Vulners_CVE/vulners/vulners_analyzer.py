#!/usr/bin/env python3
# encoding: utf-8

import os
import json
import sys
import traceback
from cortexutils.analyzer import Analyzer
from vulners import VulnersApi


class VulnersAnalyzer(Analyzer):
    def __init__(self):
        Analyzer.__init__(self)
        self.api_key = os.environ.get('VULNERS_API_KEY')
        if not self.api_key:
            self.api_key = self.get_param('config.key', None)
            if not self.api_key:
                raise ValueError("No Vulners API key provided. Please set VULNERS_API_KEY environment variable or provide it in the configuration.")

        self.vulners_client = VulnersApi(api_key=self.api_key)

    def summary(self, raw):
        taxonomies = []

        # Add CVSS score if available
        if 'cvss' in raw and raw['cvss']:
            cvss_score = float(raw['cvss'].get('score', 0))
            level = 'info'
            if cvss_score >= 7.0:
                level = 'high'
            elif cvss_score >= 4.0:
                level = 'medium'
            elif cvss_score > 0:
                level = 'low'

            taxonomies.append(self.build_taxonomy(level, 'Vulners', 'CVSS', str(cvss_score)))

        # Add vulnerability status if available
        if 'vulnStatus' in raw:
            taxonomies.append(self.build_taxonomy('info', 'Vulners', 'Status', raw['vulnStatus']))

        return {"taxonomies": taxonomies}

    def run(self):
        try:
            if self.data_type == 'cve':
                cve_id = self.get_data()

                # Normalize and validate CVE ID format (e.g., CVE-YYYY-NNNNN)
                import re

                # Normalize CVE ID (remove spaces, convert to uppercase)
                cve_id = cve_id.strip().upper().replace(" ", "")

                # Validate CVE ID format
                if not re.match(r'^CVE-\d{4}-\d{1,}$', cve_id):
                    self.error(f"Invalid CVE ID format: {cve_id}. Expected format: CVE-YYYY-NNNNN")
                    return

                # Query Vulners API for the CVE
                result = self.vulners_client.search.get_bulletin(cve_id)

                # Check if the result is empty or doesn't contain expected data
                if not result or not isinstance(result, dict):
                    self.error(f"No information found for CVE ID: {cve_id}")
                    return

                # Return the result
                self.report({'raw': result})
            else:
                self.error('Invalid data type. Expected: cve')
        except Exception as e:
            self.error(f"Error: {str(e)}\n{traceback.format_exc()}")


if __name__ == '__main__':
    VulnersAnalyzer().run()
