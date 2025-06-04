import numpy as np
import matplotlib.pyplot as plt

# Load data from breakout board tutorial workflow
suffix = '2024-08-22T14_16_06'; # Change to match file names' suffix
plt.close('all')

#%% Metadata
dt = {'names': ('time', 'acq_clk_hz', 'block_read_sz', 'block_write_sz'),
      'formats': ('datetime64[us]', 'u4', 'u4', 'u4')}
meta = np.genfromtxt('start-time_' + suffix + '.csv', delimiter=',', dtype=dt)
print(f"Recording was started at {meta['time']} GMT")

#%% Analog Inputs
analog_input = {}
analog_input['time'] = np.fromfile('analog-clock_' + suffix + '.raw', dtype=np.uint64) / meta['acq_clk_hz']
analog_input['data'] = np.reshape(np.fromfile('analog-data_' + suffix + '.raw', dtype=np.float32), (-1, 12))

plt.figure()
plt.plot(analog_input['time'], analog_input['data'])
plt.xlabel("time (sec)")
plt.ylabel("volts")
plt.legend(['Ch. 0', 'Ch. 1', 'Ch. 2', 'Ch. 3', 'Ch. 4', 'Ch. 5', 
            'Ch. 6', 'Ch. 7', 'Ch. 8', 'Ch. 9', 'Ch. 10', 'Ch. 11'])

#%% Hardware FIFO buffer use
dt = {'names': ('clock', 'bytes', 'percent'),
      'formats': ('u8', 'u4', 'f8')}
memory_use = np.genfromtxt('memory-use_' + suffix + '.csv', delimiter=',', dtype=dt)

plt.figure()
plt.plot(memory_use['clock'] / meta['acq_clk_hz'], memory_use['percent'])
plt.xlabel("time (sec)")
plt.ylabel("FIFO used (%)")
