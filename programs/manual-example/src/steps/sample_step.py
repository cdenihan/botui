from libstp.motor import Motor
from libstp.step import Step


class SampleStep(Step):
    pass


# TODO: @dsl decorator is not defined - implement or import from appropriate module
def sample_step(my_arg: bool, other_arg: str, sensor: Motor) -> SampleStep:
    return SampleStep()