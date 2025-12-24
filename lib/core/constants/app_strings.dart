/// App Strings - Centralized string constants for the application
/// All UI strings should be defined here for easy maintenance and future i18n support
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // ==================== CATEGORIES ====================
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';
  static const String thisWeek = 'This Week';
  static const String planned = 'Planned';
  static const String completed = 'Completed';
  static const String trash = 'Trash';
  static const String projects = 'Projects';
  static const String tags = 'Tags';

  // ==================== COMMON LABELS ====================
  static const String search = 'Search...';
  static const String searchIn = 'Search in';
  static const String searchInTrash = 'Search in trash...';
  static const String searchCompletedTasks = 'Search completed tasks';
  static const String enterTaskName = 'Enter task name...';
  static const String addTask = 'Add a task';
  static const String addATask = 'Add a Task...';
  static const String untitledTask = 'Untitled Task';
  static const String untitledSubtask = 'Untitled Subtask';
  static const String noProject = 'No Project';
  static const String projectNotFound = 'Project Not Found';
  static const String undefinedProject = 'Undefined Project';
  static const String noTasks = 'No tasks in';
  static const String selected = 'selected';

  // ==================== TASK DETAIL LABELS ====================
  static const String status = 'Status';
  static const String completedStatus = 'Completed';
  static const String notCompleted = 'Not Completed';
  static const String dueDate = 'Due Date';
  static const String priority = 'Priority';
  static const String notSet = 'Not Set';
  static const String project = 'Project';
  static const String reminder = 'Reminder';
  static const String repeat = 'Repeat';
  static const String none = 'None';
  static const String notes = 'Notes';
  static const String attachments = 'Attachments';
  static const String noAttachments = 'No attachments';
  static const String subtasks = 'Subtasks';
  static const String pomodoro = 'Pomodoro';
  static const String subtaskName = 'Subtask name';

  // ==================== ACTION BUTTONS ====================
  static const String add = 'Add';
  static const String addSubtask = 'Add subtask';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String deleteTask = 'Delete Task';
  static const String deletePermanently = 'Delete Permanently';
  static const String restore = 'Restore';
  static const String archive = 'Archive';
  static const String edit = 'Edit';
  static const String saveChanges = 'Save Changes';
  static const String save = 'Save';
  static const String searchButton = 'Search';
  static const String otherActions = 'Other actions...';

  // ==================== SORT OPTIONS ====================
  static const String sortByTitle = 'Sort by Title';
  static const String sortByDueDate = 'Sort by Due Date';
  static const String sortByPriority = 'Sort by Priority';
  static const String sortByDeletedDate = 'Sort by Deleted Date';
  static const String selectMultiple = 'Select Multiple';

  // ==================== STATS LABELS ====================
  static const String totalEstimatedTime = 'Total Estimated Time';
  static const String completedTime = 'Completed Time';
  static const String pendingTasks = 'Pending Tasks';
  static const String completedTasks = 'Completed Tasks';
  static const String taskCompletedToday = 'Task Completed Today';
  static const String taskCompletedThisWeek = 'Task Completed This Week';
  static const String taskCompletedThisTwoWeeks = 'Task Completed This Two...';
  static const String taskCompletedThisMonth = 'Task Completed This Month';

  // ==================== PROJECT & TAG MANAGEMENT ====================
  static const String manageProjectsAndTags = 'Manage Projects and Tags';
  static const String projectName = 'Project Name';
  static const String tagName = 'Tag Name';
  static const String color = 'Color';
  static const String tagColor = 'Tag Color';
  static const String noArchivedProjects = 'No archived projects';
  static const String noArchivedTags = 'No archived tags';
  static const String restoreProject = 'Restore project';
  static const String restoreTag = 'Restore tag';
  static const String archivedProjects = 'Archived Projects';
  static const String archivedTags = 'Archived Tags';
  static const String addNewProject = 'Add New Project';
  static const String addNewTag = 'Add New Tag';
  static const String addProject = 'Add Project';
  static const String addTag = 'Add Tag';
  static const String exampleProjectName = 'Example: Final Flutter Project';
  static const String exampleTagName = 'Example: Important, Housework';

  // ==================== EMPTY STATES ====================
  static const String trashIsEmpty = 'Trash is empty.';
  static const String noCompletedTasks = 'No completed tasks.';
  static const String taskNotFound = 'Task not found.';
  static const String projectIdPrefix = 'Project ID:';

  // ==================== SUCCESS MESSAGES ====================
  static const String taskCreatedSuccessfully = 'Task created successfully!';
  static const String taskRestoredSuccessfully = 'Task restored successfully!';
  static const String taskDeletedPermanently = 'Task deleted permanently!';
  static const String taskMovedToTrash = 'Task moved to trash!';
  static const String taskRestored = 'Task restored successfully!';
  static const String tasksRestored = 'task(s) restored!';
  static const String tasksDeletedPermanently = 'task(s) deleted permanently!';
  static const String projectAddedSuccessfully = 'Project added successfully!';
  static const String projectUpdatedSuccessfully = 'Project updated successfully!';
  static const String projectRestored = 'Project restored successfully!';
  static const String projectDeletedPermanently = 'Project deleted permanently!';
  static const String tagAddedSuccessfully = 'Tag added successfully!';
  static const String tagUpdatedSuccessfully = 'Tag updated successfully!';
  static const String tagRestored = 'Tag restored successfully!';
  static const String tagDeletedPermanently = 'Tag deleted permanently!';

  // ==================== ERROR MESSAGES ====================
  static const String pleaseEnterTaskName = 'Please enter a task name!';
  static const String pleaseEnterProjectName = 'Please enter a project name!';
  static const String pleaseEnterTagName = 'Please enter a tag name!';
  static const String pleaseSelectProjectColor = 'Please select a color for the project!';
  static const String pleaseSelectProjectIcon = 'Please select an icon for the project!';
  static const String pleaseSelectTagColor = 'Please select a text color for the tag!';
  static const String pleaseLoginToContinue = 'Please login to continue.';
  static const String errorCreatingTask = 'Error creating task:';
  static const String errorRestoring = 'Error restoring:';
  static const String errorRestoringTask = 'Error restoring task:';
  static const String errorDeleting = 'Error deleting:';
  static const String errorDeletingProjectColon = 'Error deleting project:';
  static const String errorDeletingTagColon = 'Error deleting tag:';
  static const String errorAddingProject = 'Error adding project:';
  static const String errorUpdatingProject = 'Error updating project:';
  static const String errorDeletingProject = 'Error deleting project:';
  static const String errorAddingTag = 'Error adding tag:';
  static const String errorUpdatingTag = 'Error updating tag:';
  static const String errorDeletingTag = 'Error deleting tag:';
  static const String errorPrefix = 'Error:';
  static const String cannotUpdateTask = 'Cannot update task. Please try again.';
  static const String cannotUpdateProject = 'Cannot update project. Please try again.';
  static const String cannotUpdateTag = 'Cannot update tag. Please try again.';
  static const String cannotLoadTagData = 'Cannot load tag data for editing.';
  static const String cannotLoadProjectData = 'Cannot load project data.';

  // ==================== EXCEPTION MESSAGES ====================
  static const String userNotLoggedIn = 'User not logged in';
  static const String noPermission = 'You don\'t have permission';
  static const String cannotUpdate = 'Cannot update';
  static const String notFound = 'Not found';
  static const String projectNameExists = 'Project name already exists';
  static const String tagNameExists = 'Tag name already exists';
  static const String projectNotExistOrNoPermissionToEdit = 'Project does not exist or you don\'t have permission to edit.';
  static const String tagNotExistOrNoPermissionToEdit = 'Tag does not exist or you don\'t have permission to edit.';
  static const String projectNotExistOrNoPermissionToArchive = 'Project does not exist or you don\'t have permission to archive.';
  static const String tagNotExistOrNoPermissionToArchive = 'Tag does not exist or you don\'t have permission to archive.';
  static const String projectNotExistOrNoPermissionToRestore = 'Project does not exist or you don\'t have permission to restore.';
  static const String tagNotExistOrNoPermissionToRestore = 'Tag does not exist or you don\'t have permission to restore.';
  static const String noPermissionToAddTask = 'You need to login to add tasks!';
  static const String noPermissionToAddProject = 'You need to login to add projects!';
  static const String noPermissionToAddTag = 'You need to login to add tags!';
  static const String noPermissionToUpdateTask = 'You don\'t have permission to update this task.';
  static const String noPermissionToDeleteTask = 'You don\'t have permission to delete this task.';
  static const String noPermissionToRestoreTask = 'You don\'t have permission to restore this task.';
  static const String taskIdCannotBeNull = 'Task ID cannot be null or empty';
  static const String projectIdCannotBeEmpty = 'Project ID cannot be empty when updating';
  static const String tagIdCannotBeEmpty = 'Tag ID cannot be empty when updating';

  // ==================== CONFIRMATION DIALOGS ====================
  static const String confirmDeleteTask = 'Are you sure you want to permanently delete task';
  static const String confirmMoveToTrash = 'will be moved to trash. Do you want to continue?';
  static const String confirmPermanentDeleteTask = 'Are you sure you want to permanently delete task';
  static const String confirmDeleteMultipleTasks = 'Are you sure you want to permanently delete';
  static const String confirmDeleteProject = 'Are you sure you want to permanently delete project';
  static const String confirmDeleteTag = 'Are you sure you want to permanently delete tag';
  static const String actionCannotBeUndone = 'This action cannot be undone and will remove this';
  static const String fromAllRelatedTasks = 'from all related tasks.';
  static const String tasks = 'tasks';
  static const String task = 'task';

  // ==================== TOOLTIPS ====================
  static const String startPomodoroForTask = 'Start Pomodoro for this task';
  static const String saveProjectTooltip = 'Save Project';
  static const String saveTagTooltip = 'Save Tag';
  static const String saveChangesTooltip = 'Save Changes';

  // ==================== TASK LIST SCREEN ====================
  static const String projectNotFoundMessage = 'Project not found with ID';
  
  // ==================== OTHER ====================
  static const String editFunctionalityNotImplemented = 'Edit task functionality not yet implemented.';
  static const String otherActionsMenu = 'Other actions...';
}