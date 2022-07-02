#!/usr/bin/env python3
import os

from aws_cdk import App

from stacks.l7_load_balancing import L7LoadBalancingStack


app = App()
L7LoadBalancingStack(app, "L7-LB-Demo")

app.synth()
