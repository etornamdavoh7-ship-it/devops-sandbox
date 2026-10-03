import React, { useState, useEffect } from "react";
import axios from "axios";
import ResourceForm from "./components/ResourceForm";
import ResourceList from "./components/ResourceList";
import Toast from "./components/Toast";
import { Plus, BookOpen } from "lucide-react";

const API_URL = import.meta.env.VITE_API_URL || "/api";

function App() {
  const [resources, setResources] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [editingResource, setEditingResource] = useState(null);
  const [toast, setToast] = useState({ show: false, message: "", type: "" });

  const showToast = (message, type = "success") => {
    setToast({ show: true, message, type });
    setTimeout(() => setToast({ show: false, message: "", type: "" }), 3000);
  };

  useEffect(() => {
    const fetchResources = async () => {
      try {
        const response = await axios.get(`${API_URL}/resources`);
        setResources(response.data);
      } catch (error) {
        console.error("Error fetching resources:", error);
        showToast("Error loading resources", "error");
      }
    };

    fetchResources();
  }, []); // Empty dependency array is fine now

  const addResource = async (resourceData) => {
    try {
      const response = await axios.post(`${API_URL}/resources`, resourceData);
      setResources([response.data, ...resources]);
      setShowForm(false);
      showToast("Resource added successfully!");
    } catch (error) {
      console.error("Error adding resource:", error);
      showToast("Error adding resource", "error");
    }
  };

  const updateResource = async (id, updates) => {
    try {
      const response = await axios.put(`${API_URL}/resources/${id}`, updates);
      setResources(
        resources.map((res) => (res._id === id ? response.data : res)),
      );
      setEditingResource(null);
      showToast("Resource updated successfully!");
    } catch (error) {
      console.error("Error updating resource:", error);
      showToast("Error updating resource", "error");
    }
  };

  const deleteResource = async (id) => {
    if (window.confirm("Are you sure you want to delete this resource?")) {
      try {
        await axios.delete(`${API_URL}/resources/${id}`);
        setResources(resources.filter((res) => res._id !== id));
        showToast("Resource deleted successfully!");
      } catch (error) {
        console.error("Error deleting resource:", error);
        showToast("Error deleting resource", "error");
      }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-8">
      <div className="max-w-6xl mx-auto px-4">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="flex items-center justify-center gap-3 mb-4">
            <div className="p-3 bg-blue-600 rounded-full">
              <BookOpen className="text-white" size={32} />
            </div>
            <h1 className="text-4xl font-bold text-gray-900">
              Developer Resource Tracker
            </h1>
          </div>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            Organize and track your learning resources in one place. Never lose
            track of important tutorials, articles, or courses again.
          </p>
        </div>

        {/* Stats & Add Button */}
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
          <div className="bg-white rounded-lg shadow-sm px-6 py-4">
            <div className="flex items-center gap-6">
              <div className="text-center">
                <div className="text-2xl font-bold text-blue-600">
                  {resources.length}
                </div>
                <div className="text-sm text-gray-500">Total Resources</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-green-600">
                  {resources.filter((r) => r.completed).length}
                </div>
                <div className="text-sm text-gray-500">Completed</div>
              </div>
            </div>
          </div>

          <button
            onClick={() => setShowForm(!showForm)}
            className="flex items-center gap-3 bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg shadow-md transition-all duration-200 hover:shadow-lg"
          >
            <Plus size={20} />
            {showForm ? "Cancel" : "Add New Resource"}
          </button>
        </div>

        {/* Form */}
        {showForm && (
          <ResourceForm
            onSubmit={addResource}
            onCancel={() => setShowForm(false)}
          />
        )}

        {/* Resource List */}
        <ResourceList
          resources={resources}
          onEdit={setEditingResource}
          onUpdate={updateResource}
          onDelete={deleteResource}
          editingResource={editingResource}
          onCancelEdit={() => setEditingResource(null)}
        />

        {/* Toast Notification */}
        <Toast {...toast} />
      </div>
    </div>
  );
}

export default App;
