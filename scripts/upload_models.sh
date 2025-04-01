AWS_DEFAULT_REGION=us-east-1

# 1. SSM into EC2
aws ssm start-session --target "$(aws ec2 describe-instances --filters "Name=tag:Name,Values=ComfyUIStack/Host" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[InstanceId]' --output text)" --region $AWS_DEFAULT_REGION

# 2. SSH into Container
container_id=$(sudo docker container ls | grep "/opt/nvidia/nvidia_" | awk '{print $1}')
sudo docker exec -it $container_id /bin/bash

# 3. install models, loras, controlnets or whatever you need (you can also include all in a script and execute it to install)

# SD 1.5
wget -c https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors -P ./models/checkpoints/ 

# SDXL 1.0
wget -c https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors -P ./models/checkpoints/ 

# Blue Pencil XL
wget -c "https://civitai.com/api/download/models/592322?type=Model&format=SafeTensor&size=pruned&fp=fp16" -O ./models/checkpoints/BluePencilXL_V7-0-0.safetensors 

# Animagine XL v4.0
wget -c https://huggingface.co/cagliostrolab/animagine-xl-4.0/resolve/main/animagine-xl-4.0.safetensors -P ./models/checkpoints/  
# Animagine XL v4.0 opt
wget -c https://huggingface.co/cagliostrolab/animagine-xl-4.0/resolve/main/animagine-xl-4.0-opt.safetensors -P ./models/checkpoints/  
# Animagine XL v4.0 zero
wget -c https://huggingface.co/cagliostrolab/animagine-xl-4.0-zero/resolve/main/animagine-xl-4.0-zero.safetensors -P ./models/checkpoints/  

# Juggernaut XL Inpainting
wget -c "https://civitai.com/api/download/models/456538?type=Model&format=SafeTensor&size=pruned&fp=fp16" -O ./models/checkpoints/Juggernaut-XL-inpainting.safetensors

# RealVisXL v5.0
wget -c "https://civitai.com/api/download/models/798204?type=Model&format=SafeTensor&size=full&fp=fp16" -O ./models/checkpoints/RealVisXL-v5-0_fp16.safetensors

# Atomix Anime XL
wget -c "https://civitai.com/api/download/models/413937?type=Model&format=SafeTensor&size=pruned&fp=fp16" -O ./models/checkpoints/atomix_anime_xl.safetensors


# LoRA
wget -c "https://civitai.com/api/download/models/348189?type=Model&format=SafeTensor" -O ./models/loras/glowneon_xl_v1.safetensors 
wget -c "https://civitai.com/api/download/models/277389?type=Model&format=SafeTensor" -O ./models/loras/ral-dissolve-sdxl.safetensors
wget -c "https://civitai.com/api/download/models/275849?type=Model&format=SafeTensor" -O ./models/loras/Dark_Futuristic_Circuit_Board.safetensors
wget -c https://huggingface.co/ostris/watercolor_style_lora_sdxl/resolve/main/watercolor_v1_sdxl.safetensors -P ./models/loras/

# ControlNet SDXL
wget -c https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors -O ./models/controlnet/controlnet-union-sdxl-1.0-promax.safetensors
wget -c https://huggingface.co/2vXpSwA7/iroiro-lora/resolve/main/test_controlnet2/CN-anytest_v4-marged.safetensors -P ./models/controlnet/

# CLIP Vision
wget -c https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors -O ./models/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors
wget -c https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors -O ./models/clip_vision/CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors

# IP-Adapter
wget -c https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors -P ./models/ipadapter

# AnimateDiff
wget -c https://huggingface.co/hotshotco/Hotshot-XL/resolve/main/hsxl_temporal_layers.f16.safetensors -P ./models/animatediff_models
wget -c https://huggingface.co/guoyww/animatediff/resolve/main/mm_sdxl_v10_beta.ckpt -P ./models/animatediff_models


# 素材のダウンロード
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/landscape_01.jpeg?raw=true -O ./input/landscape_01.jpeg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/landscape_02.jpg?raw=true -O ./input/landscape_02.jpg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/fire_castle.jpeg?raw=true -O ./input/fire_castle.jpeg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/girl_01.jpg?raw=true -O ./input/girl_01.jpg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/girl_02.jpg?raw=true -O ./input/girl_02.jpeg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/videos/man_dancing_720_1280_25fps.mp4 -P ./input/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/videos/720p_girl_selfie_01.mp4 -P ./input/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/blank_space.png?raw=true -O ./input/blank_space.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/boy_01.png?raw=true -O ./input/boy_01.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/boy_02.jpeg?raw=true -O ./input/boy_02.jpeg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/boy_03.png?raw=true -O ./input/boy_03.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/butterfly_01.png?raw=true -O ./input/butterfly_01.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/cosmetics.png?raw=true -O ./input/cosmetics.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/comfyui-master-guide_flyer.webp?raw=true -O ./input/comfyui-master-guide_flyer.webp
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/dog_anime_01.png?raw=true -O ./input/dog_anime_01.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/girl-for-controlnet.jpeg?raw=true -O ./input/girl-for-controlnet.jpeg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/girl_anime_02.jpeg?raw=true -O ./input/girl_anime_02.jpeg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/people.jpg?raw=true -O ./input/people.jpg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/real_girl_06.jpg?raw=true -O ./input/real_girl_06.jpg
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/scribble_01.png?raw=true -O ./input/scribble_01.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/workflow_sdxl_lora.png?raw=true -O ./input/workflow_sdxl_lora.png
wget -c https://github.com/aicuai/Book-SD-MasterGuide/blob/main/images/白無地_Tシャツ_表裏.png?raw=true -O ./input/白無地_Tシャツ_表裏.png

# ワークフローのダウンロード
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_t-shirt-design-front-and-back.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_remove_objects_by_inpainting.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_regenerate_background.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_extract_line.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_envy-zoom-slider-xl_with_xy-plot.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_envy-zoom-slider-xl.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_detail-tweaker-xl_with_xy-plot.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_controlnet_tile_upscale.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_detail-tweaker-xl.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_change_hair.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_blank_space_image_generation.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_v2v_with_lora.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_v2v_real2anime.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_v2v.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_t2v_with_ipadapter.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_t2v.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_real2anime.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_i2v.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_animatediff_create_background.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow-illustration-to-real-with-controlnet.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow-animateDiff-t2v-fromZero.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/ipadapter_basic.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/inpaint_advanced.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/i2i_transform_style.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/controlnet_tile_upscale.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/controlnet_scribble.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/controlnet_depth.json -P ./user/default/workflows/
wget -c https://github.com/aicuai/Book-SD-MasterGuide/raw/refs/heads/main/workflows/workflow_sdxl_lora.json -P ./user/default/workflows/
