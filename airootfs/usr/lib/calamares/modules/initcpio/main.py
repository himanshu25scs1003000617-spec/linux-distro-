#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Calamares python fallback module for mkinitcpio

import libcalamares

def run():
    libcalamares.utils.target_env_call(["mkinitcpio", "-P"])
    return None
