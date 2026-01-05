import Artifact from "../models/Artifact.js";

export const createArtifact = async (req, res) => {
  try {
    const data = req.body;
    // يمكنك إضافة createdBy: req.user.id إن كان محميًا
    const artifact = await Artifact.create({ ...data, createdBy: req.user?.id });
    res.status(201).json(artifact);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const getArtifacts = async (req, res) => {
  try {
    const artifacts = await Artifact.find().sort({ createdAt: -1 });
    res.json(artifacts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const getArtifact = async (req, res) => {
  try {
    const artifact = await Artifact.findById(req.params.id);
    if (!artifact) return res.status(404).json({ message: "Not found" });
    res.json(artifact);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const updateArtifact = async (req, res) => {
  try {
    const artifact = await Artifact.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(artifact);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export const deleteArtifact = async (req, res) => {
  try {
    await Artifact.findByIdAndDelete(req.params.id);
    res.json({ message: "Deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
