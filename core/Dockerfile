ARG BASE_IMAGE
FROM ${BASE_IMAGE:-jack60612/easyid-pre:cpu-main} AS core_step

ARG BE_VERSION
ARG APP_VERSION_STRING
ENV BE_VERSION=$BE_VERSION
ENV APP_VERSION_STRING=$APP_VERSION_STRING
ENV HOME=/app/ml
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV PYTHONUNBUFFERED=0
ENV JOBLIB_MULTIPROCESSING=0

# download ML models
ARG INTEL_OPTIMIZATION=false
ARG GPU_IDX=-1
ENV GPU_IDX=$GPU_IDX INTEL_OPTIMIZATION=$INTEL_OPTIMIZATION
ARG FACE_DETECTION_PLUGIN="facenet.FaceDetector"
ARG CALCULATION_PLUGIN="facenet.Calculator"
ARG EXTRA_PLUGINS="facenet.LandmarksDetector,agegender.AgeDetector,agegender.GenderDetector,facenet.facemask.MaskDetector,facenet.PoseEstimator"
ENV FACE_DETECTION_PLUGIN=$FACE_DETECTION_PLUGIN CALCULATION_PLUGIN=$CALCULATION_PLUGIN \
    EXTRA_PLUGINS=$EXTRA_PLUGINS
#COPY src src
#COPY srcext srcext
RUN cp -r /tmp/compreface/embedding-calculator/src . && cp -r /tmp/compreface/embedding-calculator/srcext .
RUN python -m src.services.facescan.plugins.setup

# copy rest of the code
#COPY tools tools
#COPY sample_images sample_images
RUN cp -r /tmp/compreface/embedding-calculator/tools . && cp -r /tmp/compreface/embedding-calculator/sample_images .

# run tests
ARG SKIP_TESTS
#COPY pytest.ini .
RUN cp /tmp/compreface/embedding-calculator/pytest.ini .
RUN if [ -z $SKIP_TESTS  ]; then pytest -m "not performance" /app/ml/src; fi

EXPOSE 3000

#COPY uwsgi.ini .
RUN cp /tmp/compreface/embedding-calculator/uwsgi.ini . && rm -rf /tmp/compreface
CMD ["uwsgi", "--ini", "uwsgi.ini"]
LABEL org.opencontainers.image.source=https://github.com/jack60612/easyID-server
LABEL org.opencontainers.image.description="Image For Facial Recognition"