import express from "express";
import {
  createArtifact,
  getArtifacts,
  getArtifact,
  updateArtifact,
  deleteArtifact
} from "../controllers/artifactController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/", getArtifacts);
router.get("/:id", getArtifact);
router.post("/", protect, createArtifact); // حماية لإنشاء أثر
router.put("/:id", protect, updateArtifact);
router.delete("/:id", protect, deleteArtifact);

export default router;
