import React, { useState } from 'react';
import { ExternalLink, Edit2, Trash2, Check, X, Calendar, Building } from 'lucide-react';
import ResourceForm from './ResourceForm';

const ResourceItem = ({ 
  resource, 
  onEdit, 
  onUpdate, 
  onDelete, 
  isEditing,
  onCancelEdit 
}) => {
  const [completed, setCompleted] = useState(resource.completed);

  const handleToggleComplete = async () => {
    const newCompleted = !completed;
    setCompleted(newCompleted);
    await onUpdate(resource._id, { completed: newCompleted });
  };

  const priorityColors = {
    High: 'bg-red-100 text-red-800 border-red-300',
    Medium: 'bg-yellow-100 text-yellow-800 border-yellow-300',
    Low: 'bg-green-100 text-green-800 border-green-300'
  };

  const categoryColors = {
    Frontend: 'bg-blue-100 text-blue-800',
    Backend: 'bg-purple-100 text-purple-800',
    Database: 'bg-orange-100 text-orange-800',
    DevOps: 'bg-indigo-100 text-indigo-800',
    Other: 'bg-gray-100 text-gray-800'
  };

  if (isEditing) {
    return (
      <ResourceForm
        initialData={resource}
        onSubmit={(data) => onUpdate(resource._id, data)}
        onCancel={onCancelEdit}
      />
    );
  }

  return (
    <div className={`bg-white rounded-xl shadow-sm border-l-4 p-6 transition-all duration-200 hover:shadow-md ${
      completed ? 'border-l-green-500 opacity-75' : 
      resource.priority === 'High' ? 'border-l-red-500' :
      resource.priority === 'Medium' ? 'border-l-yellow-500' : 'border-l-green-500'
    }`}>
      <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-4">
        {/* Content */}
        <div className="flex-1">
          <div className="flex flex-wrap items-center gap-2 mb-3">
            <h3 className={`text-xl font-semibold ${completed ? 'line-through text-gray-500' : 'text-gray-900'}`}>
              {resource.title}
            </h3>
            <span className={`px-3 py-1 rounded-full text-sm font-medium border ${priorityColors[resource.priority]}`}>
              {resource.priority}
            </span>
            {completed && (
              <span className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium border border-green-300">
                Completed
              </span>
            )}
          </div>
          
          {/* Meta Information */}
          <div className="flex flex-wrap items-center gap-4 text-sm text-gray-600 mb-4">
            <span className={`px-3 py-1 rounded-full font-medium ${categoryColors[resource.category]}`}>
              {resource.category}
            </span>
            
            {resource.source && (
              <span className="flex items-center gap-1">
                <Building size={16} />
                {resource.source}
              </span>
            )}
            
            <span className="flex items-center gap-1">
              <Calendar size={16} />
              {new Date(resource.createdAt).toLocaleDateString()}
            </span>
          </div>

          {/* URL */}
          <a 
            href={resource.url} 
            target="_blank" 
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 text-blue-600 hover:text-blue-800 font-medium transition-colors"
          >
            <ExternalLink size={18} />
            Visit Resource
            <span className="text-sm text-gray-500 truncate max-w-xs">
              ({resource.url})
            </span>
          </a>
        </div>

        {/* Actions */}
        <div className="flex gap-2 lg:flex-col">
          <button
            onClick={handleToggleComplete}
            className={`p-3 rounded-lg transition-colors ${
              completed 
                ? 'bg-green-100 text-green-600 hover:bg-green-200' 
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
            title={completed ? 'Mark as incomplete' : 'Mark as complete'}
          >
            {completed ? <Check size={20} /> : <X size={20} />}
          </button>
          
          <button
            onClick={() => onEdit(resource)}
            className="p-3 bg-blue-100 text-blue-600 rounded-lg hover:bg-blue-200 transition-colors"
            title="Edit resource"
          >
            <Edit2 size={20} />
          </button>
          
          <button
            onClick={() => onDelete(resource._id)}
            className="p-3 bg-red-100 text-red-600 rounded-lg hover:bg-red-200 transition-colors"
            title="Delete resource"
          >
            <Trash2 size={20} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ResourceItem;