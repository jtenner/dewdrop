"""Record only snapshot-generator subprocess calls; preserve normal results."""
import json
import os
import pathlib
import subprocess
import time

_original_run = subprocess.run

def _timed_snapshot_run(command, *args, **kwargs):
    if not isinstance(command, (list, tuple)) or not command:
        return _original_run(command, *args, **kwargs)
    if pathlib.Path(str(command[0])).name != 'module_snapshot_gen.exe':
        return _original_run(command, *args, **kwargs)
    destination = os.environ.get('DEW_SNAPSHOT_COMPILER_TIMING_PATH')
    if not destination:
        return _original_run(command, *args, **kwargs)
    started = time.perf_counter()
    status = None
    error = None
    try:
        result = _original_run(command, *args, **kwargs)
        status = result.returncode
        return result
    except BaseException as failure:
        error = type(failure).__name__ + ': ' + str(failure)
        raise
    finally:
        record = {'argv': [str(value) for value in command],
                  'cwd': str(kwargs.get('cwd', os.getcwd())),
                  'seconds': time.perf_counter() - started,
                  'exit': status}
        if error is not None:
            record['error'] = error
        descriptor = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o600)
        try:
            os.write(descriptor, (json.dumps(record, separators=(',', ':')) + '\n').encode())
        finally:
            os.close(descriptor)

subprocess.run = _timed_snapshot_run
