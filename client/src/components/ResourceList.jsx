import React from 'react';
import ResourceItem from './ResourceItem';

const ResourceList = ({ 
  resources, 
  onEdit, 
  onUpdate, 
  onDelete, 
  editingResource,
  onCancelEdit 
}) => {
  if (resources.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow-md p-8 text-center">
        <p className="text-gray-500 text-lg">No resources added yet.</p>
        <p className="text-gray-400">Add your first learning resource to get started!</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {resources.map(resource => (
        <ResourceItem
          key={resource._id}
          resource={resource}
          onEdit={onEdit}
          onUpdate={onUpdate}
          onDelete={onDelete}
          isEditing={editingResource?._id === resource._id}
          onCancelEdit={onCancelEdit}
        />
      ))}
    </div>
  );
};

export default ResourceList;