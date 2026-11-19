# Project-VenaVision

A near-infrared (NIR) vein visualization system that captures images of veins beneath the skin and stores them on a local web server for viewing through a web interface.

## *I know what I want, and I want it now.*
## *I want you, cause I'm Mr. Vein.*

Inspired by the song *[Mr. Vain](https://en.wikipedia.org/wiki/Mr._Vain)* by Culture Beat. We figured the name was too good to pass up.

## About the project

VenaVision is an embedded systems project built around a Raspberry Pi 4 Model B. The system uses near-infrared illumination and a NoIR camera to capture images of veins beneath the skin.

When an arm is positioned within the desired distance, an ultrasonic sensor triggers the image capture process. The captured image is then transferred over a private network to a Linux-based web server, where it can be accessed through a Flask web interface.

## Main components

- **Raspberry Pi 4 Model B:** Controls the hardware and coordinates the system.
- **Pi Camera NoIR:** Captures images under near-infrared illumination.
- **NIR LED ring:** Illuminates the area being examined.
- **Ultrasonic distance sensor:** Detects when an arm is positioned within the desired distance.
- **Python:** Handles hardware control, image capture and system logic.
- **SFTP:** Securely transfers captured images to the web server.
- **Flask:** Provides the web interface for viewing captured images.

## Project objectives

The goal is to develop a working prototype that combines embedded systems, networking and software development into a single solution.

The project focuses on:
- Integrating and controlling hardware components through the Raspberry Pi.
- Capturing images using near-infrared illumination.
- Automating image capture based on distance detection.
- Transferring images securely over a private network.
- Making captured images accessible through a web interface.

## Project status

This project is being developed as part of the 3rd semester IT-Technologist programme at Erhvervsakademi København (EK).