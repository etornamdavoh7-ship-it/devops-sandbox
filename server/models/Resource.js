import mongoose from 'mongoose';

const resourceSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  url: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    default: 'Other'
  },
  priority: {
    type: String,
    enum: ['High', 'Medium', 'Low'],
    default: 'Medium'
  },
  completed: {
    type: Boolean,
    default: false
  },
  source: {
    type: String,
    default: ''
  }
}, {
  timestamps: true
});

export default mongoose.model('Resource', resourceSchema);