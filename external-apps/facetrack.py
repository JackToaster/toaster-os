from picamera2 import Picamera2, Preview
import time
import onnxruntime
import numpy as np
import cv2

import pyvirtualcam

import subprocess

from pythonosc.udp_client import SimpleUDPClient

from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import asyncio

osc_ip_rcv = "127.0.0.1"
osc_port_rcv = 8889

osc_ip = "127.0.0.1"
osc_port =  8888
osc_client = SimpleUDPClient(osc_ip, osc_port)  # Create osc client

def output_osc(array):
    location = ""
    max_clip_value = 1
    # Apply the multiplier and then clip the values between 0 and 1
    clipped_array = np.clip(array, 0, max_clip_value)
    osc_client.send_message(location + "/cheekPuffLeft", float(clipped_array[0]))
    osc_client.send_message(location + "/cheekPuffRight", float(clipped_array[1]))
    osc_client.send_message(location + "/cheekSuckLeft", float(clipped_array[2]))
    osc_client.send_message(location + "/cheekSuckRight", float(clipped_array[3]))
    osc_client.send_message(location + "/jawOpen", float(clipped_array[4]))
    osc_client.send_message(location + "/jawForward", float(clipped_array[5]))
    osc_client.send_message(location + "/jawLeft", float(clipped_array[6]))
    osc_client.send_message(location + "/jawRight", float(clipped_array[7]))
    osc_client.send_message(location + "/noseSneerLeft", float(clipped_array[8]))
    osc_client.send_message(location + "/noseSneerRight", float(clipped_array[9]))
    osc_client.send_message(location + "/mouthFunnel", float(clipped_array[10]))
    osc_client.send_message(location + "/mouthPucker", float(clipped_array[11]))
    osc_client.send_message(location + "/mouthLeft", float(clipped_array[12]))
    osc_client.send_message(location + "/mouthRight", float(clipped_array[13]))
    osc_client.send_message(location + "/mouthRollUpper", float(clipped_array[14]))
    osc_client.send_message(location + "/mouthRollLower", float(clipped_array[15]))
    osc_client.send_message(location + "/mouthShrugUpper", float(clipped_array[16]))
    osc_client.send_message(location + "/mouthShrugLower", float(clipped_array[17]))
    osc_client.send_message(location + "/mouthClose", float(clipped_array[18]))
    osc_client.send_message(location + "/mouthSmileLeft", float(clipped_array[19]))
    osc_client.send_message(location + "/mouthSmileRight", float(clipped_array[20]))
    osc_client.send_message(location + "/mouthFrownLeft", float(clipped_array[21]))
    osc_client.send_message(location + "/mouthFrownRight", float(clipped_array[22]))
    osc_client.send_message(location + "/mouthDimpleLeft", float(clipped_array[23]))
    osc_client.send_message(location + "/mouthDimpleRight", float(clipped_array[24]))
    osc_client.send_message(location + "/mouthUpperUpLeft", float(clipped_array[25]))
    osc_client.send_message(location + "/mouthUpperUpRight", float(clipped_array[26]))
    osc_client.send_message(location + "/mouthLowerDownLeft", float(clipped_array[27]))
    osc_client.send_message(location + "/mouthLowerDownRight", float(clipped_array[28]))
    osc_client.send_message(location + "/mouthPressLeft", float(clipped_array[29]))
    osc_client.send_message(location + "/mouthPressRight", float(clipped_array[30]))
    osc_client.send_message(location + "/mouthStretchLeft", float(clipped_array[31]))
    osc_client.send_message(location + "/mouthStretchRight", float(clipped_array[32]))
    osc_client.send_message(location + "/tongueOut", float(clipped_array[33]))
    osc_client.send_message(location + "/tongueUp", float(clipped_array[34]))
    osc_client.send_message(location + "/tongueDown", float(clipped_array[35]))
    osc_client.send_message(location + "/tongueLeft", float(clipped_array[36]))
    osc_client.send_message(location + "/tongueRight", float(clipped_array[37]))
    osc_client.send_message(location + "/tongueRoll", float(clipped_array[38]))
    osc_client.send_message(location + "/tongueBendDown", float(clipped_array[39]))
    osc_client.send_message(location + "/tongueCurlUp", float(clipped_array[40]))
    osc_client.send_message(location + "/tongueSquish", float(clipped_array[41]))
    osc_client.send_message(location + "/tongueFlat", float(clipped_array[42]))
    osc_client.send_message(location + "/tongueTwistLeft", float(clipped_array[43]))
    osc_client.send_message(location + "/tongueTwistRight", float(clipped_array[44]))


subprocess.run(["./virtual-cam-setup.sh"], shell=True)


picam2 = Picamera2()

picam2.configure(picam2.create_preview_configuration(main={"format": 'XRGB8888', "size": (640, 480)}))
picam2.start()

sess_opt = onnxruntime.SessionOptions()
sess_opt.intra_op_num_threads = 2

#sess_opt.execution_mode  = onnxruntime.ExecutionMode.ORT_PARALLEL
#sess_opt.inter_op_num_threads = 2

providers = [("ACLExecutionProvider", {"enable_fast_math": "true"})]

session = onnxruntime.InferenceSession("model.onnx", sess_opt, providers=providers)
#session = onnxruntime.InferenceSession("model.onnx", sess_opt)

input_name = session.get_inputs()[0].name
output_name = session.get_outputs()[0].name

def normalize(numpy_array):
    """
    Normalize the values of a numpy array to a specified range.

    Args:
    - numpy_array (numpy.ndarray): Input numpy array.

    Returns:
    - numpy.ndarray: Normalized numpy array.
    """
    normalized_array = numpy_array / 255

    return normalized_array


def to_tensor(numpy_array, dtype=np.float32):
    """
    Convert a numpy array to a PyTorch tensor.

    Args:
    - numpy_array (numpy.ndarray): Input numpy array.
    - dtype (numpy.dtype): Data type of the resulting PyTorch tensor.

    Returns:
    - torch.Tensor: Converted PyTorch tensor.
    """
    if not isinstance(numpy_array, np.ndarray):
        raise ValueError("Input must be a numpy array")

    # Ensure the input array has the correct data type
    numpy_array = numpy_array.astype(dtype)

    # Add a batch dimension if the input array is 2D
    if len(numpy_array.shape) == 2:
        numpy_array = numpy_array[:, :, np.newaxis]

    # Transpose the array to match PyTorch tensor format (C x H x W)
    tensor = normalize(np.transpose(numpy_array, (2, 0, 1)))

    return tensor


def unsqueeze(numpy_array, axis: int):
    """
    Add a dimension of size 1 to a numpy array at the specified position.

    Args:
    - numpy_array (numpy.ndarray): Input numpy array.
    - axis (int): Position along which to add the new dimension.

    Returns:
    - numpy.ndarray: Numpy array with an additional dimension.
    """
    if not isinstance(numpy_array, np.ndarray):
        raise ValueError("Input must be a numpy array")

    result_array = np.expand_dims(numpy_array, axis=axis)

    return result_array


import queue

mouth_roi = (0.0,0.0,1.0,1.0)
roi_queue = queue.Queue()
roi_queue.put(mouth_roi)

def adjust_roi(address, *args):
    print(f"ROI Adjustment {address}: {args}")
    if len(args) != 4:
        print("invalid roi!")
    mouth_roi = (float(args[0]),float(args[1]),float(args[2]),float(args[3]))
    roi_queue.put(mouth_roi)

def osc_command_handler(address, *args):
    print(f"{address}: {args}")


dispatcher = Dispatcher()
dispatcher.map("/example", osc_command_handler)
dispatcher.map("/roi/mouth", adjust_roi)


async def loop():
    # not using pyvirtualcam anymore because Godot can't handle the pixel format for some reason
    # with pyvirtualcam.Camera(width=224, height=224, fps=15, fmt=pyvirtualcam.PixelFormat.I420) as cam:
    #     print(f'Using virtual camera: {cam.device}')
    mouth_roi = roi_queue.get()
    while True:
        im = picam2.capture_array()
        

        im = cv2.rotate(im, cv2.ROTATE_90_COUNTERCLOCKWISE)

        start_time = time.time()
        grey = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
        frame_size = grey.shape
        h, w = frame_size[0:2]
        # frame_roi = grey[0:10,0:480]
        #print(f"roi: {mouth_roi}") #aaaa
        try:
            mouth_roi = roi_queue.get(False)
        except queue.Empty:
            pass
        frame_roi = grey[int(mouth_roi[1]*h):int(mouth_roi[3]*h), int(mouth_roi[0]*w):int(mouth_roi[2]*w)]
        disp_frame = cv2.resize(frame_roi, (224,224), interpolation=cv2.INTER_LINEAR)
        
        #color_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2YUV_I420)
        #cam.send(color_frame)

        # color converted already
        # frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        frame = to_tensor(disp_frame)
        frame = unsqueeze(frame, 0)

        output = session.run([output_name], {input_name:frame})
        output = output[0][0]

    #    print(f"{round((time.time() - start_time) * 1000, 2)}ms")
        output_osc(output)
        #print(output)
        
        await asyncio.sleep(0.01)
#        cv2.imshow("Camera", grey)
        cv2.imshow("ROI", disp_frame)
        cv2.waitKey(1)




async def init_main():
    server = AsyncIOOSCUDPServer((osc_ip_rcv, osc_port_rcv), dispatcher, asyncio.get_event_loop())
    transport, protocol = await server.create_serve_endpoint()  # Create datagram endpoint and start serving

    await loop()  # Enter main loop of program

    transport.close()  # Clean up serve endpoint


asyncio.run(init_main())