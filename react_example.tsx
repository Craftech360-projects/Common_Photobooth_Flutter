import React, { useState, useRef, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import Webcam from 'react-webcam';
import { Camera as CameraIcon, RefreshCw, ChevronLeft, Upload } from 'lucide-react';
import { Button } from '../components/Button';
import { supabase } from '../lib/supabase';
import { toast } from '../components/Toaster';

const Camera: React.FC = () => {
  const navigate = useNavigate();
  const webcamRef = useRef<Webcam>(null);
  const [imgSrc, setImgSrc] = useState<string | null>(null);
  const [isFacingUser, setIsFacingUser] = useState(true);
  const [isUploading, setIsUploading] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [processingProgress, setProcessingProgress] = useState(0);
  
  // Get userId from session storage
  const userId = sessionStorage.getItem('userId');
  
  // Redirect if no userId is found
  if (!userId) {
    // We should check this on component mount, but for simplicity in this example
    // we'll just inline it
    React.useEffect(() => {
      toast.error('User information not found. Please register first.');
      navigate('/');
    }, [navigate]);
  }

  const videoConstraints = {
    width: 1280,
    height: 720,
    facingMode: isFacingUser ? 'user' : 'environment',
  };

  const capture = useCallback(() => {
    const imageSrc = webcamRef.current?.getScreenshot();
    if (imageSrc) {
      setImgSrc(imageSrc);
    }
  }, [webcamRef]);

  const retake = () => {
    setImgSrc(null);
  };

  const toggleCamera = () => {
    setIsFacingUser(!isFacingUser);
  };

  const uploadImage = async () => {
    if (!imgSrc || !userId) {
      toast.error('No image captured or user information missing.');
      return;
    }

    setIsUploading(true);
    setIsProcessing(true);
    setProcessingProgress(0);

    try {
      // Generate new random refresh trigger value
      const newRefreshTrigger = Math.floor(Math.random() * 1000000);
      setRefreshTrigger(newRefreshTrigger);

      // Start progress simulation
      const progressInterval = setInterval(() => {
        setProcessingProgress(prev => {
          if (prev >= 95) {
            clearInterval(progressInterval);
            return prev;
          }
          return prev + 1;
        });
      }, 300);

      // Convert base64 to blob
      const res = await fetch(imgSrc);
      const blob = await res.blob();
      
      // Upload to Supabase Storage
      const fileName = `user_photo_${userId}_${new Date().getTime()}.png`;
      const { data: storageData, error: storageError } = await supabase.storage
        .from('inputimages')
        .upload(fileName, blob, {
          contentType: 'image/png',
        });
      
      if (storageError) {
        throw storageError;
      }
      
      // Get the public URL
      const { data: publicUrlData } = supabase.storage
        .from('inputimages')
        .getPublicUrl(fileName);
      
      const photoUrl = publicUrlData.publicUrl;
      
      // Update user record with photo URL
      const { error: updateError } = await supabase
        .from('inputimagetable')
        .update({ image_url: photoUrl })
        .eq('id', userId);
      
      if (updateError) {
        throw updateError;
      }

      // Keep the existing workflow object
      const workflow = {
      "4": {
    "inputs": {
      "PowerLoraLoaderHeaderWidget": {
        "type": "PowerLoraLoaderHeaderWidget"
      },
      "lora_1": {
        "on": true,
        "lora": "Disco_Elysium_Potrait_Style.safetensors",
        "strength": 1.3
      },
      "lora_2": {
        "on": true,
        "lora": "flux-depth-dev-lora.safetensors",
        "strength": 0.9
      },
      "lora_3": {
        "on": true,
        "lora": "FLUX.1-Turbo-Alpha.safetensors",
        "strength": 1
      },
      "lora_4": {
        "on": true,
        "lora": "Aesthetic-texture-enhancer.safetensors",
        "strength": 0.8
      },
      "lora_5": {
        "on": true,
        "lora": "Organic-Sauce-flux.safetensors",
        "strength": 0.3
      },
      "➕ Add Lora": "",
      "model": [
        "39",
        0
      ],
      "clip": [
        "39",
        1
      ]
    },
    "class_type": "Power Lora Loader (rgthree)",
    "_meta": {
      "title": "Power Lora Loader (rgthree)"
    }
  },
  "5": {
    "inputs": {
      "text": [
        "61",
        0
      ],
      "clip": [
        "4",
        1
      ]
    },
    "class_type": "CLIPTextEncode",
    "_meta": {
      "title": "CLIP Text Encode (Prompt)"
    }
  },
  "6": {
    "inputs": {
      "conditioning": [
        "5",
        0
      ]
    },
    "class_type": "ConditioningZeroOut",
    "_meta": {
      "title": "ConditioningZeroOut"
    }
  },
  "7": {
    "inputs": {
      "guidance": 10,
      "conditioning": [
        "5",
        0
      ]
    },
    "class_type": "FluxGuidance",
    "_meta": {
      "title": "FluxGuidance"
    }
  },
  "8": {
    "inputs": {
      "positive": [
        "7",
        0
      ],
      "negative": [
        "6",
        0
      ],
      "vae": [
        "39",
        2
      ],
      "pixels": [
        "17",
        0
      ]
    },
    "class_type": "InstructPixToPixConditioning",
    "_meta": {
      "title": "InstructPixToPixConditioning"
    }
  },
  "9": {
    "inputs": {
      "seed": 783575377922782,
      "steps": 12,
      "cfg": 1,
      "sampler_name": "euler",
      "scheduler": "beta",
      "denoise": 1,
      "model": [
        "32",
        0
      ],
      "positive": [
        "25",
        0
      ],
      "negative": [
        "8",
        1
      ],
      "latent_image": [
        "8",
        2
      ]
    },
    "class_type": "KSampler",
    "_meta": {
      "title": "KSampler"
    }
  },
  "11": {
    "inputs": {
      "samples": [
        "9",
        0
      ],
      "vae": [
        "39",
        2
      ]
    },
    "class_type": "VAEDecode",
    "_meta": {
      "title": "VAE Decode"
    }
  },
  "17": {
    "inputs": {
      "ckpt_name": "depth_anything_v2_vitl.pth",
      "resolution": 1024,
      "image": [
        "50",
        0
      ]
    },
    "class_type": "DepthAnythingV2Preprocessor",
    "_meta": {
      "title": "Depth Anything V2 - Relative"
    }
  },
  "21": {
    "inputs": {
      "images": [
        "17",
        0
      ]
    },
    "class_type": "PreviewImage",
    "_meta": {
      "title": "Preview Image"
    }
  },
  "23": {
    "inputs": {
      "text": [
        "28",
        2
      ],
      "text_1": "The image is a portrait of a young woman's head and upper body, painted in a realistic style. The woman is facing towards the left side of the image, with a serious expression on her face. She is wearing a blue headscarf that covers her head, which is tied in a neat knot at the top of her head. The headband is made of a light blue fabric with a white stripe running horizontally across it. The fabric appears to be slightly wrinkled and faded, giving it a worn and aged appearance. The background is black, making the woman's face and head stand out. The painting is done in a loose, loose style, with loose brushstrokes that create a sense of depth and texture. The colors used in the painting are mostly earthy tones, with hints of yellow, brown, and white. The overall mood of the painting is somber and contemplative.",
      "text_2": "The image is a portrait of the late American pop artist, Michael Jackson. He is standing with his body slightly turned to the side, with his hands on his hips. His head is turned slightly to the left, and his eyes are looking directly at the camera. His hair is styled in a messy, curly manner, and he is wearing a black jacket with silver studs on the sleeves and cuffs. The jacket has a high collar and a button-down front. He also has a silver belt with a silver buckle. The background is white, making the black jacket stand out."
    },
    "class_type": "ShowText|pysssss",
    "_meta": {
      "title": "Show Text 🐍"
    }
  },
  "25": {
    "inputs": {
      "downsampling_factor": 2,
      "downsampling_function": "area",
      "mode": "center crop (square)",
      "weight": 0.8,
      "autocrop_margin": 0.1,
      "conditioning": [
        "8",
        0
      ],
      "style_model": [
        "26",
        0
      ],
      "clip_vision": [
        "27",
        0
      ],
      "image": [
        "50",
        0
      ]
    },
    "class_type": "ReduxAdvanced",
    "_meta": {
      "title": "ReduxAdvanced"
    }
  },
  "26": {
    "inputs": {
      "style_model_name": "flux1-redux-dev.safetensors"
    },
    "class_type": "StyleModelLoader",
    "_meta": {
      "title": "Load Style Model"
    }
  },
  "27": {
    "inputs": {
      "clip_name": "sigclip_vision_patch14_384.safetensors"
    },
    "class_type": "CLIPVisionLoader",
    "_meta": {
      "title": "Load CLIP Vision"
    }
  },
  "28": {
    "inputs": {
      "text_input": "",
      "task": "more_detailed_caption",
      "fill_mask": true,
      "keep_model_loaded": false,
      "max_new_tokens": 1024,
      "num_beams": 3,
      "do_sample": true,
      "output_mask_select": "",
      "seed": 600418659008593,
      "image": [
        "50",
        0
      ],
      "florence2_model": [
        "29",
        0
      ]
    },
    "class_type": "Florence2Run",
    "_meta": {
      "title": "Florence2Run"
    }
  },
  "29": {
    "inputs": {
      "model": "gokaygokay/Florence-2-Flux-Large",
      "precision": "fp16",
      "attention": "sdpa"
    },
    "class_type": "DownloadAndLoadFlorence2Model",
    "_meta": {
      "title": "DownloadAndLoadFlorence2Model"
    }
  },
  "32": {
    "inputs": {
      "weight": 0.9,
      "start_at": 0,
      "end_at": 1,
      "model": [
        "4",
        0
      ],
      "pulid_flux": [
        "33",
        0
      ],
      "eva_clip": [
        "34",
        0
      ],
      "face_analysis": [
        "35",
        0
      ],
      "image": [
        "50",
        0
      ]
    },
    "class_type": "ApplyPulidFlux",
    "_meta": {
      "title": "Apply PuLID Flux"
    }
  },
  "33": {
    "inputs": {
      "pulid_file": "pulid_flux_v0.9.1.safetensors"
    },
    "class_type": "PulidFluxModelLoader",
    "_meta": {
      "title": "Load PuLID Flux Model"
    }
  },
  "34": {
    "inputs": {},
    "class_type": "PulidFluxEvaClipLoader",
    "_meta": {
      "title": "Load Eva Clip (PuLID Flux)"
    }
  },
  "35": {
    "inputs": {
      "provider": "CUDA"
    },
    "class_type": "PulidFluxInsightFaceLoader",
    "_meta": {
      "title": "Load InsightFace (PuLID Flux)"
    }
  },
  "37": {
    "inputs": {
      "upscale_method": "lanczos",
      "megapixels": 1,
      "image": [
        "62",
        0
      ]
    },
    "class_type": "ImageScaleToTotalPixels",
    "_meta": {
      "title": "Scale Image to Total Pixels"
    }
  },
  "39": {
    "inputs": {
      "ckpt_name": "fluxdev.safetensors"
    },
    "class_type": "CheckpointLoaderSimple",
    "_meta": {
      "title": "Load Checkpoint"
    }
  },
  "40": {
    "inputs": {
      "size": "custom",
      "custom_width": 824,
      "custom_height": 824,
      "color": "#fff"
    },
    "class_type": "LayerUtility: ColorImage V2",
    "_meta": {
      "title": "LayerUtility: ColorImage V2"
    }
  },
  "41": {
    "inputs": {
      "image": [
        "37",
        0
      ]
    },
    "class_type": "GetImageSize+",
    "_meta": {
      "title": "🔧 Get Image Size"
    }
  },
  "42": {
    "inputs": {
      "width": 512,
      "height": 512,
      "upscale_method": "lanczos",
      "keep_proportion": false,
      "divisible_by": 2,
      "width_input": [
        "41",
        0
      ],
      "height_input": [
        "41",
        1
      ],
      "crop": "disabled",
      "image": [
        "40",
        0
      ]
    },
    "class_type": "ImageResizeKJ",
    "_meta": {
      "title": "Resize Image"
    }
  },
  "50": {
    "inputs": {
      "overlay_resize": "None",
      "resize_method": "nearest-exact",
      "rescale_factor": 1,
      "width": 512,
      "height": 512,
      "x_offset": 0,
      "y_offset": 0,
      "rotation": 0,
      "opacity": 0,
      "base_image": [
        "42",
        0
      ],
      "overlay_image": [
        "37",
        0
      ],
      "optional_mask": [
        "62",
        1
      ]
    },
    "class_type": "Image Overlay",
    "_meta": {
      "title": "Image Overlay"
    }
  },
  "60": {
    "inputs": {
      "text": "oil painting portrait rendered in a loose, impressionistic style with thick, expressive brush strokes, abstract expressionist portrait, traditional painting, harsh brushstrokes, colorful abstract background, disco elysium, [a monkey warrior]"
    },
    "class_type": "CR Text",
    "_meta": {
      "title": "🔤 CR Text"
    }
  },
  "61": {
    "inputs": {
      "text": "oil painting portrait rendered in a loose, impressionistic style with thick, expressive brush strokes, abstract expressionist portrait, traditional painting, harsh brushstrokes, colorful abstract background, disco elysium, [character description]",
      "old": "character description",
      "new": [
        "28",
        2
      ]
    },
    "class_type": "Replace Text _O",
    "_meta": {
      "title": "Replace Text _O"
    }
  },
  "62": {
    "inputs": {
      "supabase_url": "https://popppjirsdedxhetcphs.supabase.co",
      "supabase_key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvcHBwamlyc2RlZHhoZXRjcGhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3NjMxMDAsImV4cCI6MjA1OTMzOTEwMH0.Ihv60cbfUSeDN5dPDsOZRz4y79ek3D5YZZgKwBsMkSc",
      "table_name": "inputimagetable",
      "image_column": "image_url",
      "refresh_trigger": newRefreshTrigger
    },
    "class_type": "SupabaseTableWatcherNode",
    "_meta": {
      "title": "Supabase Table Watcher"
    }
  },
  "63": {
    "inputs": {
      "supabase_url": "https://popppjirsdedxhetcphs.supabase.co",
      "supabase_key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvcHBwamlyc2RlZHhoZXRjcGhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM3NjMxMDAsImV4cCI6MjA1OTMzOTEwMH0.Ihv60cbfUSeDN5dPDsOZRz4y79ek3D5YZZgKwBsMkSc",
      "bucket": "outputimages",
      "base_file_name": "image",
      "image": [
        "11",
        0
      ]
    },
    "class_type": "SupabaseImageUploader",
    "_meta": {
      "title": "Upload Image to Supabase"
    }
  }
      };

      await sendWorkflowToBackend(
        
        workflow 
      );
      
      toast.success('Photo uploaded successfully!');
      navigate('/success');
    } catch (error) {
      console.error('Error uploading photo:', error);
      toast.error('Failed to upload photo. Please try again.');
    } finally {
      setIsUploading(false);
    }
  };


  

  const sendWorkflowToBackend = async (workflowData: any) => {
    try {
      const response = await fetch('http://localhost:3001/prompt', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(workflowData),
      });
      
      if (!response.ok) {
        const errorData = await response.text();
        throw new Error(`Workflow submission failed: ${errorData}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error sending workflow:', error);
      throw error; // Re-throw the error to be handled by the caller
    }
  };

  return (
    <div className="min-h-screen bg-neutral-900 flex flex-col">
      <div className="p-4">
        <Button 
          variant="ghost" 
          size="sm" 
          className="text-white" 
          onClick={() => navigate('/')}
          icon={<ChevronLeft className="h-4 w-4" />}
        >
          Back to Registration
        </Button>
      </div>
      
      <div className="flex-1 flex flex-col items-center justify-center p-4">
        <div className="w-full max-w-md mb-4">
          <div className="text-center mb-6">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-blue-500 rounded-full mb-4">
              <CameraIcon className="h-8 w-8 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-white">Take Your Photo</h1>
            <p className="text-neutral-300 mt-2">
              Position your face in the frame and click the capture button
            </p>
          </div>
          
          <div className="relative bg-black rounded-xl overflow-hidden shadow-lg">
            {imgSrc ? (
              <img 
                src={imgSrc} 
                alt="Captured" 
                className="w-full h-auto aspect-video object-cover"
              />
            ) : (
              <Webcam
                audio={false}
                ref={webcamRef}
                screenshotFormat="image/png"
                videoConstraints={videoConstraints}
                className="w-full h-auto"
              />
            )}
          </div>
          
          <div className="flex justify-center mt-6 space-x-4">
            {imgSrc ? (
              <>
                <Button 
                  variant="secondary" 
                  onClick={retake}
                  icon={<RefreshCw className="h-4 w-4" />}
                  disabled={isUploading || isProcessing}
                >
                  Retake
                </Button>
                <Button 
                  onClick={uploadImage} 
                  isLoading={isUploading || isProcessing}
                  disabled={isUploading || isProcessing}
                  icon={<Upload className="h-4 w-4" />}
                >
                  {isProcessing ? `Processing (${processingProgress}%)` : 
                   isUploading ? 'Uploading...' : 
                   'Upload & Continue'}
                </Button>
              </>
            ) : (
              <>
                <Button 
                  variant="secondary" 
                  onClick={toggleCamera}
                  icon={<RefreshCw className="h-4 w-4" />}
                >
                  Flip Camera
                </Button>
                <Button onClick={capture}>
                  Capture Photo
                </Button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Camera;
